// pb_hooks/main.pb.js
onBeforeServe((e) => {
  e.next()
  // อนุญาตทุก origin สำหรับทดสอบ (เปิด CORS)
  e.response.headers.add("Access-Control-Allow-Origin", "*")
  e.response.headers.add("Access-Control-Allow-Methods", "GET, POST, PATCH, PUT, DELETE, OPTIONS")
  e.response.headers.add("Access-Control-Allow-Headers", "Content-Type, Authorization")
})
