import express from "express";
import { createServer } from "http";
import { Server } from "ws";
import { config } from "dotenv";
import { join } from "path";

import scriptRoute from "./routes/scripts"
import { websocketCon } from "./routes/scripts";

const app = express();
const server = createServer(app);
const wss = new Server({ server, path: "/scripts/fates-admin/chat" });

config({ path: join(__dirname, "./.env") });

app.use("/scripts/fates-admin", scriptRoute);
wss.on("connection", websocketCon);

server.listen(80, () => console.log("server running on port 80"));

export { server, wss }

module.exports = app