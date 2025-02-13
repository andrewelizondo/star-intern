package models

import "mime/multipart"

type Request struct {
	File *multipart.FileHeader `form:"file" binding:"required"`
}
