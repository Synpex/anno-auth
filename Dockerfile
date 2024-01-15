# ---- Base Stage ----
FROM node:20 AS base
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --only=production
COPY . .

# ---- Build Stage ----
FROM base AS build
RUN npm install --only=development
RUN npx prisma generate
RUN npm run build

# ---- Final Stage ----
FROM node:20-alpine AS final
WORKDIR /usr/src/app
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/package.json ./package.json

EXPOSE 3333
CMD ["node", "dist/main"]
