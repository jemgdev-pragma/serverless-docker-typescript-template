import { requestSaveUserSchema } from '@config/schema/save-user.schema'
import LambdaLogger from '@libraries/logger'
import { UserModel } from '@models/user.model'
import { UserMemoryService } from "@services/user-memory.service"

export class SaveUserApp {
  constructor (private readonly userService: UserMemoryService) {}

  async invoke (user: Pick<UserModel, 'username' | 'password' | 'avatar'>) {
    try {
      const { error, value } = requestSaveUserSchema.validate(user)

      LambdaLogger.info({
        code: 'VALIDATE_SAVE_USER',
        message: 'Validate save user',
        metadata: {
          value,
          error: error?.message || 'No errors'
        }
      })

      if (error) {
        throw error
      }

      await this.userService.saveUser({
        ...user,
        id: crypto.randomUUID()
      })

      return user
    } catch (error) {
      throw error
    }
  }
}