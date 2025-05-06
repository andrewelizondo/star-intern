package models

import "mime/multipart"

type Request struct {
	Instruct     string                `form:"instruct" binding:"omitempty"`
	File         *multipart.FileHeader `form:"file" binding:"omitempty"`
	InstructJson string                `json:"instruct_json" binding:"omitempty"`
}
