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

	/* Argument index */
	int i, cur;

	/* Return variables */
	int ret;
	LPSTR values[argc - 1];

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
		"%s type ...\n\n"
		"Where type is one of:\n"
		"lcid,\n"
		"[iso|abbr|native]ctry,\n"
		"[iso|abbr|native]lang.", argv[0]);
		return EXIT_SUCCESS;
	}

	for (i = 1; i < argc; i++) {
		cur = i - 1; /* Index in value array */
		
		/* Mapping table from argument string to LCTYPE */
		if (0 == StrCmpI(argv[i], "lcid")) {
			type = LOCALE_ILANGUAGE;
		} else if (0 == StrCmpI(argv[i], "ctry")) {
			type = LOCALE_SENGCOUNTRY;
		} else if (0 == StrCmpI(argv[i], "lang")) {
			type = LOCALE_SENGLANGUAGE;
		} else if (0 == StrCmpI(argv[i], "isoctry")) {
			type = LOCALE_SISO3166CTRYNAME;
		} else if (0 == StrCmpI(argv[i], "isolang")) {
			type = LOCALE_SISO639LANGNAME;
		} else if (0 == StrCmpI(argv[i], "abbrctry")) {
			type = LOCALE_SABBREVCTRYNAME;
		} else if (0 == StrCmpI(argv[i], "abbrlang")) {
			type = LOCALE_SABBREVLANGNAME;
		} else if (0 == StrCmpI(argv[i], "nativectry")) {
			type = LOCALE_SNATIVECTRYNAME;
		} else if (0 == StrCmpI(argv[i], "nativelang")) {
			type = LOCALE_SNATIVELANGNAME;
		} else {
			/* Invalid argument, just die without output */
			ret = EXIT_FAILURE;
			goto cleanup;
		}

		/* Create a string to store return value in */
		values[cur] = new char[length];

		ret = GetLocaleInfo(
				LOCALE_SYSTEM_DEFAULT,
				type,
				values[cur],
				length);
	}

	printf("%s", values[0]);
	
	for (i = 1, cur = argc - 1; i < cur; i++) {
		printf(" %s", values[i]);
	}

	ret = EXIT_SUCCESS;
	goto cleanup;

/* Cleanup */
cleanup:
	cur = i;
	for (i = 1; i < cur; i++) {
		delete []values[i];
	}

	return ret;
}
