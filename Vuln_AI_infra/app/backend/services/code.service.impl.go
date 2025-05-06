package services

import (
	"context"
	"errors"
	"github.com/andrewelizondo/star-intern/v2/models"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/bedrockagentruntime"
	"github.com/aws/aws-sdk-go-v2/service/bedrockagentruntime/types"
	"github.com/google/uuid"
	"io"
	"log/slog"
	"mime/multipart"
	"os"
	"strings"
)

var (
	agentId      = os.Getenv("AGENT_ID")
	agentAliasId = os.Getenv("AGENT_ALIAS_ID")
)

type CodeServiceImpl struct {
	ctx context.Context
}

func NewCodeServiceImpl(ctx context.Context) CodeServiceImpl {
	return CodeServiceImpl{
		ctx: ctx,
	}
}

func (c CodeServiceImpl) ProcessCode(req *models.Request) (*models.Response, error) {
	instructText := strings.Builder{}
	if req.Instruct != "" {
		instructText.WriteString(req.Instruct)
		instructText.WriteString("\n")
	}
	if req.InstructJson != "" {
		instructText.WriteString(req.InstructJson)
		instructText.WriteString("\n")
	}
	if req.File != nil {
		fileText, err := getStringFromFileHeader(req.File)
		if err != nil {
			slog.Warn("Error reading file", "error", err)
		} else {
			instructText.WriteString(fileText)
		}
	}
	if instructText.Len() == 0 {
		return nil, errors.New("No instruction text provided")
	} else {
		sessionId := uuid.New().String()
		output, err := invokeAgent(agentId, agentAliasId, sessionId, instructText.String())
		if err == nil && output != nil {
			responseBytes := []byte{}
			slog.Info("Response received from agent", "response", output)
			stream := output.GetStream()
			for event := range stream.Events() {
				if chunk, ok := event.(*types.ResponseStreamMemberChunk); ok {
					responseBytes = append(responseBytes, chunk.Value.Bytes...)
				}
			}

			response := models.Response{
				ResponseText: string(responseBytes),
			}
			return &response, stream.Close()
		} else {
			return nil, err
		}
	}
}

func getStringFromFileHeader(fileHeader *multipart.FileHeader) (string, error) {
	file, err := fileHeader.Open()
	if err != nil {
		return "", err
	}
	defer func(file multipart.File) {
		err := file.Close()
		if err != nil {
		}
	}(file)

	content, err := io.ReadAll(file)
	if err != nil {
		return "", err
	}

	return string(content), nil
}

func invokeAgent(agentId string, agentAliasId string, sessionId string, inputText string) (*bedrockagentruntime.InvokeAgentOutput, error) {
	cfg, err := config.LoadDefaultConfig(context.Background())
	if err != nil {
		return nil, err
	}

	client := bedrockagentruntime.NewFromConfig(cfg)

	input := &bedrockagentruntime.InvokeAgentInput{
		AgentId:      aws.String(agentId),
		AgentAliasId: aws.String(agentAliasId),
		SessionId:    aws.String(sessionId),
		InputText:    aws.String(inputText),
		EnableTrace:  aws.Bool(false),
		EndSession:   aws.Bool(false),
	}

	output, err := client.InvokeAgent(context.Background(), input)
	if err != nil {
		return nil, err
	}

	return output, nil
}
