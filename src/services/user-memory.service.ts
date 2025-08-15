import { UserModel } from "@models/user.model";

const usersDataBase: UserModel[] = [
  {
    id: '37afba36-1724-47a0-9f03-6cfd873e95ea',
    username: 'testuser',
    password: 'password123',
    avatar: 'https://randomuser.me/api/portraits/men/1.jpg'
  },
  {
    id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    username: 'alice',
    password: 'alicepass',
    avatar: 'https://randomuser.me/api/portraits/women/2.jpg'
  },
  {
    id: '3c4f5a36-1724-47a0-9f03-6cfd873e95ea',
    username: 'bob',
    password: 'bobpass',
    avatar: 'https://randomuser.me/api/portraits/men/3.jpg'
  },
  {
    id: '37vfba36-1724-47a0-9f03-6cfd873e95ee',
    username: 'charlie',
    password: 'charliepass',
    avatar: 'https://randomuser.me/api/portraits/men/4.jpg'
  },
  {
    id: '37afba36-1724-47a0-9f03-6cfd873e95ee',
    username: 'david',
    password: 'davidpass',
    avatar: 'https://randomuser.me/api/portraits/men/5.jpg'
  }
]

export class UserMemoryService {
  async getAllUsers(): Promise<UserModel[]> {
    try {
      return usersDataBase
    } catch (error) {
      throw new Error('Service not available')
    }
  }

  async saveUser(user: UserModel): Promise<void> {
    try {
      usersDataBase.push(user)
    } catch (error) {
      throw new Error('Service not available')
    }
  }
}