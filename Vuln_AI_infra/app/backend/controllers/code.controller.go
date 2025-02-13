package controllers

import (
	"github.com/andrewelizondo/star-intern/v2/models"
	"github.com/andrewelizondo/star-intern/v2/services"
	"github.com/gin-gonic/gin"
	"net/http"
)

type CodeController struct {
	codeService services.CodeService
}

func NewCodeController(codeService services.CodeService) CodeController {
	return CodeController{codeService: codeService}
}

func (s CodeController) Submit(context *gin.Context) {
	var req models.Request
	if err := context.ShouldBind(&req); err != nil {
		context.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request parameters. " + err.Error(), "error": err.Error()})
		return
	}
	resp, err := s.codeService.ProcessCode(&req)
	if err != nil {
		context.JSON(http.StatusInternalServerError, gin.H{"message": "Error processing code. " + err.Error(), "error": err})
		context.Abort()
		return
	}
	context.JSON(http.StatusOK, resp)
	return
}
