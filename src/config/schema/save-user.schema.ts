import { z } from 'zod'

export const requestSaveUserSchema = z.object({
  username: z.string().min(3).max(30).nonempty(),
  password: z.string().min(8).nonempty(),
  avatar: z.string().min(8).nonempty()
})