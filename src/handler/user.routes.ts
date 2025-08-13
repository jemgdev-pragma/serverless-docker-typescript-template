import { Router } from 'express'
import { UserMemoryService } from '@services/user-memory.service'
import { GetAllUsersApp } from '@app/get-all-users.app';
import { SaveUserApp } from '@app/save-user.app';

const userRouter = Router()
const getAllUsersApp = new GetAllUsersApp(new UserMemoryService())
const saveUserApp = new SaveUserApp(new UserMemoryService())

userRouter.get('/', async (_request, response, next) => {
  try {
    const users = await getAllUsersApp.invoke()

    response.status(200).json({
      code: 'SUCCESSFUL_PROCESS',
      message: 'Get all users',
      data: users
    })
  } catch (error) {
    next(error)
  }
})

userRouter.post('/', async (request, response, next) => {
  try {
    const { username, password, avatar } = request.body
    await saveUserApp.invoke({ username, password, avatar })

    response.status(201).json({
      code: 'SUCCESSFUL_PROCESS',
      message: 'User created successfully',
      data: {
        username,
        avatar
      }
    })
  } catch (error) {
    next(error)
  }
})

export { userRouter }