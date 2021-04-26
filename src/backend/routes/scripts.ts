import { Request, Response, Router } from "express"
import { wss } from "../rest";
import WebSocket from "ws";
import { IncomingMessage } from "http";
import fetch from "node-fetch";

const server = Router();

server.get("/invite", (request: Request, response: Response) => {
	response.redirect("https://discord.gg/admin");
})

server.get("/new-script", async (request: Request, response: Response) => {  
	fetch("https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua")
	.then(res => res.text())
	.then(res => {
		response.write(res);
		response.end();
	})
})

server.get("/commands", async (request: Request, response: Response) => {
	fetch("https://raw.githubusercontent.com/fatesc/fates-admin/main/src/commands/commands.html")
	.then(res => res.text())
	.then(res => {
		response.write(res);
		response.end();
	})
})

server.get("cw", (request, response) => response.send("not whitelisted"));

interface chatType {
	username: string,
	userid?: string,
	message: string,
	error: boolean,
	clientOnly: boolean
}

function sendMessageToAll(chat: chatType) {
	wss.clients.forEach(client => {
		if (client.readyState == client.OPEN) {
			client.send(JSON.stringify(chat));
		}
	});
  	if (!chat.error) {
		fetch("https://canary.discord.com/api/webhooks/836323520089817089/" + process.env.WEBHOOK, {
			method: "POST",
			headers: {
				["Content-Type"] : "application/json"
			},
			body: JSON.stringify({
				allowed_mentions: {
					"parse": []
				},
				avatar_url: `https://www.roblox.com/headshot-thumbnail/image?userId=${chat.userid}&width=150&height=150&format=png`,
				username: `${chat.username}`,
				content: `${chat.message}`
			})
		});
	}
}

let ConnectedUsers: string[] = []
const RateLimited: Map<WebSocket, number> = new Map();
// const RateLimitTimeouts: Map<WebSocket, NodeJS.Timeout> = new Map();
const RateLimitTime = 1

export function websocketCon(client: WebSocket, request: IncomingMessage) {
	const userip = request.socket.localAddress
	if (ConnectedUsers.includes(userip)) return client.close();
	ConnectedUsers.push(userip);

	sendMessageToAll({
		error: false,
		message: "a user has joined the chat",
		username: "LOG",
		clientOnly: false
	})

	client.send(JSON.stringify(<chatType>{
		error: false,
		username: "LOG",
		message: `welcome to fates admin global chat. There are currently ${Array.from(wss.clients).length} user (s) connected.`,
		clientOnly: true
	}));

	client.on("message", (msg: string) => {
		if (msg == "ping") return
		if (RateLimited.has(client)) {
			const RateLimitedTime = <number>RateLimited.get(client);
			const now = Date.now();
			const TimeLeft = (now - RateLimitedTime);
			return client.send(JSON.stringify({ error: true, username: "LOG", message: `You are being ratelimited, please wait ${((RateLimitTime * 1000) - TimeLeft) / 1000} seconds` }));  
		}
		RateLimited.set(client, Date.now());
		const Timeout = setTimeout(() => RateLimited.delete(client), RateLimitTime * 1000);
		// RateLimitTimeouts.set(client, Timeout);
	
		let message: any = {}
		try {
			message = JSON.parse(msg)
		} catch {
			return client.send(JSON.stringify(<chatType>{
				error: true,
				username: "LOG",
				message: "Not a valid message",
				clientOnly: true
			}));
		}

		if (message.message.length > 30) {
			return client.send(JSON.stringify(<chatType>{
				error: true,
				username: "LOG",
				message: "Your message is over 30 characters",
				clientOnly: true
			}))
		}

		sendMessageToAll({
			username: message.username ?? "no username",
			userid: message.userid ?? "1",
			message: message.message,
			error: false,
			clientOnly: false
		});
	});

	client.on("close", (code: number, reason: string) => {
		ConnectedUsers = ConnectedUsers.filter(a => a != userip);
	})
}

export default server
