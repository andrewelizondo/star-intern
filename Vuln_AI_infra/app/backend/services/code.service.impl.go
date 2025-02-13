package services

import (
	"context"
	"github.com/andrewelizondo/star-intern/v2/models"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/bedrockagentruntime"
	"github.com/aws/aws-sdk-go-v2/service/bedrockagentruntime/types"
	"github.com/google/uuid"
	"io"
	"mime/multipart"
	"os"
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
	inputText, err := getStringFromFileHeader(req.File)
	if err != nil {
		return nil, err
	} else {
		sessionId := uuid.New().String()
		output, err := invokeAgent(agentId, agentAliasId, sessionId, inputText)
		if err == nil && output != nil {
			responseBytes := []byte{}
			stream := output.GetStream()
			for event := range stream.Events() {
				if chunk, ok := event.(*types.ResponseStreamMemberChunk); ok {
					responseBytes = append(responseBytes, chunk.Value.Bytes...)
				}
			}
			defer func(stream *bedrockagentruntime.InvokeAgentEventStream) {
				err := stream.Close()
				if err != nil {
				}
			}(stream)

			response := models.Response{
				ResponseText: string(responseBytes),
			}
			return &response, nil
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
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		return nil, err
	}

	client := bedrockagentruntime.NewFromConfig(cfg)

	input := &bedrockagentruntime.InvokeAgentInput{
		AgentId:      &agentId,
		AgentAliasId: &agentAliasId,
		SessionId:    &sessionId,
		InputText:    &inputText,
	}

	output, err := client.InvokeAgent(context.TODO(), input)
	if err != nil {
		return nil, err
	}

	return output, nil
}
