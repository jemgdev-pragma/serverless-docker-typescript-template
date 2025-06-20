import { Router } from 'express'
import { UserMemoryRepository } from '../core/user/infrastructure/user.memory.repository';
import { GetAllUsersUseCase } from '../core/user/application/get-all-users.usecase';

const userRouter = Router()
const createUserUseCase = new GetAllUsersUseCase(new UserMemoryRepository())

userRouter.get('/', async (_request, response, next) => {
  try {
    const users = await createUserUseCase.invoke()
  
    response.status(200).json({
      code: 'SUCCESSFUL_PROCESS',
      message: 'Get all users',
      data: users
    })
  } catch (error) {
    next(error)
  }
})

export { userRouter }