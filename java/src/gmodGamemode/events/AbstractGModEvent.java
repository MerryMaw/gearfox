package gmodGamemode.events;

import java.io.PrintWriter;

import javax.servlet.http.HttpServletRequest;

public abstract class AbstractGModEvent
{
	public abstract void onInit();
	public abstract void onEvent(HttpServletRequest request, PrintWriter pr);
}
