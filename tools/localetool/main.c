/*
Copyright 2011 Michael Croes <mycroes@gmail.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <cstdlib>
#include <iostream>
#include <windows.h>
#include <shlwapi.h>

using namespace std;

int main(int argc, char *argv[])
{
	/* Request type */
	LCTYPE type;

	/* Return variables */
	int ret;
	LPSTR value;

	int length = 255;

	/* Check if we were invoked with an argument, else just die */
	if (argc < 2) {
		return EXIT_FAILURE;
	}

	if (0 == (StrCmpI(argv[1], "/?")
			* StrCmpI(argv[1], "/h")
			* StrCmpI(argv[1], "/help"))) {
		/* Help message */
		printf("Usage:\n"
		"%s type\n\n"
		"Where type is one of:\n"
		"lcid,\n"
		"[iso|abbr|native]ctry,\n"
		"[iso|abbr|native]lang.", argv[0]);
		return EXIT_SUCCESS;

	/* Mapping table from argument string to LCTYPE */
	} else if (0 == StrCmpI(argv[1], "lcid")) {
		type = LOCALE_ILANGUAGE;
	} else if (0 == StrCmpI(argv[1], "ctry")) {
		type = LOCALE_SENGCOUNTRY;
	} else if (0 == StrCmpI(argv[1], "lang")) {
		type = LOCALE_SENGLANGUAGE;
	} else if (0 == StrCmpI(argv[1], "isoctry")) {
		type = LOCALE_SISO3166CTRYNAME;
	} else if (0 == StrCmpI(argv[1], "isolang")) {
		type = LOCALE_SISO639LANGNAME;
	} else if (0 == StrCmpI(argv[1], "abbrevctry")) {
		type = LOCALE_SABBREVCTRYNAME;
	} else if (0 == StrCmpI(argv[1], "abbrevlang")) {
		type = LOCALE_SABBREVLANGNAME;
	} else if (0 == StrCmpI(argv[1], "nativectry")) {
		type = LOCALE_SNATIVECTRYNAME;
	} else if (0 == StrCmpI(argv[1], "nativelang")) {
		type = LOCALE_SNATIVELANGNAME;
	} else {
		/* Invalid argument, just die without output */
		return EXIT_FAILURE;
	}

	/* Create a string to store return value in */
	value = new char[length];

	ret = GetLocaleInfo(
			LOCALE_SYSTEM_DEFAULT,
			type,
			value,
			length);

	printf("%s", value);

	/* Cleanup */
	delete []value;

	return EXIT_SUCCESS;
}
