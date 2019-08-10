package gmodGamemode.events;

import java.io.PrintWriter;

import javax.servlet.http.HttpServletRequest;

import gmodGamemode.annotations.GModEvent;

@GModEvent(name = "gm_money")
public class GM_Money extends AbstractGModEvent
{

	@Override
	public void onInit()
	{
	}

	@Override
	public void onEvent(HttpServletRequest request, PrintWriter pr)
	{
	}
}
