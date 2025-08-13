import { Router } from 'express'
import {
  createUser,
  getAllUsers
} from '@controllers/user.controller'

const userRouter = Router()

userRouter
  .get('/', getAllUsers)
  .post('/', createUser)

export { userRouter }