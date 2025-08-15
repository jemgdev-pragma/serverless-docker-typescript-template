import { UserMemoryService } from '@services/user-memory.service'
import { GetAllUsersApp } from '@app/get-all-users.app'

describe('get-all-users test suite', () => {
  let userService: UserMemoryService
  let getAllUsersApp: GetAllUsersApp

  beforeEach(() => {
    userService = new UserMemoryService()
    getAllUsersApp = new GetAllUsersApp(userService)
  })

  it('should return all users', async () => {
    jest.spyOn(userService, 'getAllUsers').mockResolvedValue([
      {
        id: '1',
        avatar: 'https://example.com/avatar1.png',
        password: '12345678',
        username: 'test'
      }
    ])

    const users = await getAllUsersApp.invoke()
    expect(users).toEqual([
      {
        id: '1',
        avatar: 'https://example.com/avatar1.png',
        password: '12345678',
        username: 'test'
      }
    ])
  })
})