import { UserRepository } from "../domain/user.repository";

export class GetAllUsersUseCase {
  constructor (private readonly userRepository: UserRepository) {}

  async invoke () {
    try {
      const comments = await this.userRepository.getAllUsers()

      return comments
    } catch (error) {
      throw new Error('Error in list comments usecase')
    }
  }
}