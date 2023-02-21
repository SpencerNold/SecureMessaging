package me.spencernold.server.util;

import java.util.List;

public class Lists {

	public static <T> boolean contains(List<T> list, T element, Equator<T> equator) {
		for (T t : list) {
			if (equator.equal(t, element))
				return true;
		}
		return false;
	}
	
	@FunctionalInterface
	public interface Equator<T> {
		public boolean equal(T e1, T e2);
	}
}
