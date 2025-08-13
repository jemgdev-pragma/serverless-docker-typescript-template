import { UserMemoryService } from '@services/user-memory.service'

describe('get-all-users test suite', () => {
  let userService: UserMemoryService

  beforeEach(() => {
    userService = new UserMemoryService()
  })

  it('should return all users', async () => {
    const users = await userService.getAllUsers()
    expect(users.length).toEqual(5)
  })
})