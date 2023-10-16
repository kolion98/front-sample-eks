FROM node:14.15.4 as builder

# 소스 폴더 생성
RUN mkdir /usr/src/app
WORKDIR /usr/src/app
ENV PATH /usr/src/app/node_modules/.bin:$PATH
COPY package.json /usr/src/app/package.json

# 패키지 설치
RUN npm install --silent
# RUN npm install react-scripts@3.4.1 -g --silent

# 작업폴더로 복사하고 빌드
COPY . /usr/src/app
RUN npm run build

FROM nginx:latest

# 생성한 앱의 빌드산출물을 nginx의 샘플 앱이 사용하던 폴더로 이동
COPY --from=builder /usr/src/app/build /usr/share/nginx/html

# 80포트 노출 후 nginx 실행
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]