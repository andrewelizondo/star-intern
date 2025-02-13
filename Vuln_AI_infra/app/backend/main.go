package main

import (
	"context"
	"github.com/andrewelizondo/star-intern/v2/controllers"
	"github.com/andrewelizondo/star-intern/v2/routes"
	"github.com/andrewelizondo/star-intern/v2/services"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"log/slog"
	"os"
)

var (
	server *gin.Engine
	ctx    context.Context

	codeService    services.CodeService
	codeController controllers.CodeController
	codeRoutes     routes.CodeRoutes
)

func init() {
	opts := &slog.HandlerOptions{
		AddSource: true,
	}
	logger := slog.New(slog.NewJSONHandler(os.Stdout, opts))
	slog.SetDefault(logger)
	server = gin.Default()
	ctx = context.Background()

	codeService = services.NewCodeServiceImpl(ctx)
	codeController = controllers.NewCodeController(codeService)
	codeRoutes = routes.NewCodeRoutes(codeController)
}

func startServer() {
	corsConfig := cors.DefaultConfig()
	corsConfig.AllowOrigins = []string{"*"}
	corsConfig.AllowCredentials = true

	server.Use(cors.New(corsConfig))
	codeRoutes.CodeRoute(server.Group("/api"))

	server.Run(":8080")
}

func main() {
	startServer()
}
