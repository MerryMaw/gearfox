package gmodGamemode;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.concurrent.ConcurrentHashMap;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import gmodGamemode.events.AbstractGModEvent;

public class GModWebServlet extends HttpServlet
{
	private static final long serialVersionUID = 1L;

	public static ConcurrentHashMap<String, AbstractGModEvent> events = new ConcurrentHashMap<>();
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		// response.getWriter().append("Served at: ").append(request.getContextPath());
		System.out.println("GET from " + request.getRemoteAddr());

		response.setContentType("text/html");
		response.setCharacterEncoding("UTF-8");
		response.sendError(HttpServletResponse.SC_UNAUTHORIZED);

	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		System.out.println("POST from " + request.getRemoteAddr());

		response.setContentType("text/html");
		response.setCharacterEncoding("UTF-8");
		response.setStatus(HttpServletResponse.SC_ACCEPTED);

		// TODO: security check
		String event = request.getParameter("event");
		PrintWriter pr = response.getWriter();

		AbstractGModEvent e = null;

		if (event != null)
		{
			e = events.get(event);
		}

		if (e != null)
		{
			e.onEvent(request, pr);
		} else
		{
			pr.write("No event for " + String.valueOf(event));
		}

		response.flushBuffer();	
	}
	
	
	

}
