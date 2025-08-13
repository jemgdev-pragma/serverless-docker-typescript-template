import { UserMemoryService } from '@services/user-memory.service'
import { SaveUserApp } from '@app/save-user.app'

describe('save-user-app test suite', () => {
  let userService: UserMemoryService
  let saveUserApp: SaveUserApp

  beforeEach(() => {
    userService = new UserMemoryService()
    saveUserApp = new SaveUserApp(userService)
  })

  it('should save a user', async () => {
    jest.spyOn(userService, 'saveUser').mockResolvedValue()

    const users = await saveUserApp.invoke({
      avatar: 'https://example.com/avatar1.png',
      password: '12345678',
      username: 'test'
    })

    expect(userService.saveUser).toHaveBeenCalledTimes(1)
  })
})