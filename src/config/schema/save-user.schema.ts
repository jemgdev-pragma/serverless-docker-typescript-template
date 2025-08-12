import joi from 'joi'

export const requestSaveUserSchema = joi.object({
  username: joi.string().min(3).max(30).required(),
  password: joi.string().min(8).required(),
  avatar: joi.string().uri().required()
})