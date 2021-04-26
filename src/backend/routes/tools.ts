import { Request, Response, Router } from "express"

const server = Router();

server.post("/:endpoint", (request: Request, response: Response) => {
	if (request.params.endpoint) {
    response.json({
      status: "success",
      dumped: "this is no longer a thing...",
      password: "correct"
    });
  }
})
