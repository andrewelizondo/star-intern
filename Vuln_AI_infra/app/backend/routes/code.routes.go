package routes

import (
	"github.com/andrewelizondo/star-intern/v2/controllers"
	"github.com/gin-gonic/gin"
)

type CodeRoutes struct {
	codeController controllers.CodeController
}

func NewCodeRoutes(codeController controllers.CodeController) CodeRoutes {
	return CodeRoutes{codeController: codeController}
}

func (rc *CodeRoutes) CodeRoute(rg *gin.RouterGroup) {
	routerCodes := rg.Group("/codeassist")

	routerCodes.POST("/request", rc.codeController.Submit)
}
