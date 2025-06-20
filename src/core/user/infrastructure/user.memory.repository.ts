import { User } from "../domain/user";
import { UserRepository } from "../domain/user.repository";

export class UserMemoryRepository implements UserRepository {
  async getAllUsers(): Promise<User[]> {
    try {
      return [
        {
          id: '1',
          username: 'testuser',
          password: 'password123',
          avatar: 'https://randomuser.me/api/portraits/men/1.jpg'
        },
        {
          id: '2',
          username: 'alice',
          password: 'alicepass',
          avatar: 'https://randomuser.me/api/portraits/women/2.jpg'
        },
        {
          id: '3',
          username: 'bob',
          password: 'bobpass',
          avatar: 'https://randomuser.me/api/portraits/men/3.jpg'
        },
        {
          id: '4',
          username: 'charlie',
          password: 'charliepass',
          avatar: 'https://randomuser.me/api/portraits/men/4.jpg'
        },
        {
          id: '5',
          username: 'david',
          password: 'davidpass',
          avatar: 'https://randomuser.me/api/portraits/men/5.jpg'
        },
        {
          id: '6',
          username: 'eve',
          password: 'evepass',
          avatar: 'https://randomuser.me/api/portraits/women/6.jpg'
        },
        {
          id: '7',
          username: 'frank',
          password: 'frankpass',
          avatar: 'https://randomuser.me/api/portraits/men/7.jpg'
        },
        {
          id: '8',
          username: 'grace',
          password: 'gracepass',
          avatar: 'https://randomuser.me/api/portraits/women/8.jpg'
        }
      ]
    } catch (error) {
      throw new Error('Service not available')
    }
  }
}