# Step 1: TypeScript compilation
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json tsconfig.json ./
RUN npm install

COPY . .
RUN npm run build

# Step 2: Install dependencies
FROM node:18-alpine AS runner

WORKDIR /app

COPY package*.json ./
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/public ./public

RUN rm -rf ./dist/public
RUN rm -rf ./node_modules

RUN npm install --production

# Env variablews
# Server configuration
ENV PORT=''

EXPOSE 3000

CMD ["node", "dist/src/index.js"]
