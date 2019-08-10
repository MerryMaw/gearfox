package gmodGamemode.utilities;

import java.util.Set;

import org.reflections.Reflections;

import gmodGamemode.GModWebServlet;
import gmodGamemode.annotations.GModEvent;
import gmodGamemode.events.AbstractGModEvent;

public class GMod
{
	public static void loadEventsFromPackage(String pack)
	{
		System.out.println("Loading events from " + pack);
		
		Set<Class<?>> r = new Reflections(pack).getTypesAnnotatedWith(GModEvent.class);

		for (Class<?> c : r)
		{
			GModEvent an = c.getAnnotation(GModEvent.class);

			if (an != null && an.name() != null)
			{
				AbstractGModEvent e;

				try
				{
					e = (AbstractGModEvent) c.newInstance();

					GModWebServlet.events.put(an.name(), e);
					e.onInit();

					System.out.println("EVENT( " + an.name() + " ) added.");
				} catch (InstantiationException | IllegalAccessException e1)
				{
					System.out.println("EVENT( " + an.name() + " ) failed. (" + e1.getMessage() + ")");
				}
			}
			else
			{
				System.out.println("STRANGE EVENT IGNORED");
			}
		}
	}
}
