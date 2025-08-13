import { UserMemoryService } from "@services/user-memory.service";

export class GetAllUsersApp {
  constructor (private readonly userService: UserMemoryService) {}

  async invoke () {
    try {
      const users = await this.userService.getAllUsers()

      return users
    } catch (error) {
      throw error
    }
  }
}