import { Request, Response, Router } from "express"
import { wss } from "../rest";
import WebSocket from "ws";
import { IncomingMessage } from "http";
import fetch from "node-fetch";

const server = Router();

server.get("/invite", (request: Request, response: Response) => {
	response.redirect("https://discord.com/invite/5epGRYR");
})

server.get(/script|new-script/, async (request: Request, response: Response) => {
	response.write(await (await fetch("https://gitcdn.link/repo/fatesc/fates-admin/main/main.lua")).text());
	response.end();
})

server.get("/commands", async (request: Request, response: Response) => {
	response.write(await (await fetch("https://gitcdn.link/repo/fatesc/fates-admin/main/src/commands/commands.html")).text());
	response.end();
})

export namespace Chat {
	export interface Send {
		error: boolean
		username: string
		message: string
		toDiscord?: boolean
		fromDiscord?: boolean

		isAdmin?: boolean
		userid?: string
		clientOnly?: boolean
		tagColour?: number[]
	}

	export interface Recieve {
		userid: string
		username: string
		message: string
		isAdmin: boolean
		tagColour?: number[]
	}
}

function sendMessageToAll(chat: Chat.Send) {
	wss.clients.forEach(client => {
		if (client.readyState == client.OPEN) {
			client.send(JSON.stringify(chat));
		}
	});
  	if (!chat.clientOnly && chat.toDiscord) {
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
const RateLimitTime = .7

export function websocketCon(client: WebSocket, request: IncomingMessage) {
	const userip = <string>request?.headers?.["X-Forwarded-For"] ?? request?.socket?.localAddress
	if (ConnectedUsers.includes(userip)) return client.close();
	ConnectedUsers.push(userip);
	
	const parsed: Iterable<readonly [string, string]> = request.url.split(/\?|\&/).map(a => [a.split("=")[0], a.split("=")[1]]);
	const queries: Map<string, string|number> = new Map([...parsed]);

	const user = queries.get("username") ?? "a user";

	if (!user || (<string>user)?.length > 15) {
		client.send(JSON.stringify(<Chat.Send>{
			error: true,
			username: "C-LOG",
			tagColour: [100, 40, 0],
			clientOnly: true,
			message: "you don't have a username or your username is too long, please shorten it"
		}));
		return client.close();
	}

	sendMessageToAll({
		error: false,
		message: user + " has joined the chat",
		username: "G-LOG",
	});

	client.send(JSON.stringify(<Chat.Send>{
		error: false,
		username: "C-LOG",
		message: `Welcome to fates admin global chat, "C-LOG" means Client Log (log message will only be shown to you) "G-LOG" means Global Log (log message will be shown to everyone). There are currently ${Array.from(wss.clients).length} user (s) connected.`,
		tagColour: [8, 255, 8],
		clientOnly: true
	}));

	client.on("message", (msg: string) => {
		if (msg == "ping") return
		if (RateLimited.has(client)) {
			const RateLimitedTime = <number>RateLimited.get(client);
			const now = Date.now();
			const TimeLeft = (now - RateLimitedTime);
			return client.send(JSON.stringify(<Chat.Send>{ 
				error: true, 
				username: "C-LOG",
				tagColour: [255, 10, 10],
				message: `You are being ratelimited, please wait ${((RateLimitTime * 1000) - TimeLeft) / 1000} seconds`
			}));  
		}
		RateLimited.set(client, Date.now());
		const Timeout = setTimeout(() => RateLimited.delete(client), RateLimitTime * 1000);
	
		let message: Chat.Recieve
		try {
			message = JSON.parse(msg);
		} catch {
			return client.send(JSON.stringify(<Chat.Send>{
				error: true,
				username: "C-LOG",
				message: "Not a valid message",
				tagColour: [100, 40, 0],
				clientOnly: true
			}));
		}

		if (message.message.length > 30) {
			return client.send(JSON.stringify(<Chat.Send>{
				error: true,
				username: "C-LOG",
				message: "Your message is over 30 characters, your message has not been sent",
				tagColour: [255, 164, 0],
				clientOnly: true
			}));
		}

		if (queries.get("token") && queries.get("token") == process.env.TOKEN) return sendMessageToAll({
			username: message.username,
			message: message.message,
			fromDiscord: true,
			tagColour: message.isAdmin ? [77, 255, 255] : [138, 43, 226],
			error: false,  
			isAdmin: message.isAdmin
		});
		
		sendMessageToAll({
			username: message.username ?? "no username",
			userid: message.userid ?? "1",
			message: message.message,
			error: false,
			toDiscord: true
		});
	});

	client.on("close", (code: number, reason: string) => {
		ConnectedUsers = ConnectedUsers.filter(a => a != userip);
		sendMessageToAll({
			username: "G-LOG",
			message: user + " has left the chat",
			error: false
		});
	})
}

export default server
