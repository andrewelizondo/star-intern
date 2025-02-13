package services

import "github.com/andrewelizondo/star-intern/v2/models"

type CodeService interface {
	ProcessCode(req *models.Request) (*models.Response, error)
}
