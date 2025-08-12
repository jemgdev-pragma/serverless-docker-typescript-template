import { config } from 'dotenv'
config()
import express from 'express'
import { serverConfig } from '@libraries/express.config'

const app = express()
const server = serverConfig(app)

server.listen(server.get('PORT'), () => {
  console.log(`API running on port ${server.get('PORT')}`)
})