import { User } from "./user"

export interface UserRepository {
  getAllUsers (): Promise<User[]>
}