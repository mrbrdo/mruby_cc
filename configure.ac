AC_INIT([mrbcc],[0.1])
AC_CONFIG_AUX_DIR([build-aux])

dnl Needed to compile mruby.
AC_PROG_CC()
AC_PROG_YACC()

dnl Ensure ruby (at least 1.9).
AC_PROG_SED()
AC_PROG_GREP()
AC_ARG_WITH(ruby,
	AC_HELP_STRING([--with-ruby=[[[RUBY]]]],[absolute path to ruby executable]),
	[RUBY="$withval"])
AC_CHECK_PROG(RUBY, ruby, ruby)
test -z "$RUBY" && AC_MSG_FAILURE([no acceptable ruby interpreter found in \$PATH])
changequote(<<,>>)
ruby_version=`$RUBY --version 2>&1 | $GREP "^ruby " | $SED 's/^ruby \([^ ]*\)\ .*$/\1/'`
ruby_major_version=`echo $ruby_version | sed 's/^\([0-9]*\)\.[0-9]*.*/\1/'`
ruby_minor_version=`echo $ruby_version | sed 's/^[0-9]*\.\([0-9]*\).*/\1/'`
changequote([,])
test -z "$ruby_major_version" && AC_MSG_FAILURE([ruby in \$PATH does not work])
test -z "$ruby_minor_version" && AC_MSG_FAILURE([ruby in \$PATH does not work])
test "$ruby_major_version" -lt 1 && AC_MSG_FAILURE([ruby version in \$PATH is $ruby_version; must be at least 1.9])
test "$ruby_minor_version" -lt 9 && AC_MSG_FAILURE([ruby version in \$PATH is $ruby_version; must be at least 1.9])

dnl Ensure ruby gems: activesupport i18n.
AC_MSG_CHECKING([for ruby gem activesupport])
echo 'gem = Gem::Specification.find_by_name("activesupport")' | $RUBY 2>/dev/null ; gem_activesupport=$?
if test "$gem_activesupport" -eq 0 ; then AC_MSG_RESULT([ok]) ;
else AC_MSG_RESULT([no]) ; AC_MSG_FAILURE([ruby gem activesupport not found]) ; fi
AC_MSG_CHECKING([for ruby gem i18n])
echo 'gem = Gem::Specification.find_by_name("i18n")' | $RUBY 2>/dev/null ; gem_i18n=$?
if test "$gem_i18n" -eq 0 ; then AC_MSG_RESULT([ok]) ;
else AC_MSG_RESULT([no]) ; AC_MSG_FAILURE([ruby gem i18n not found]) ; fi

dnl Ensure git.
AC_ARG_WITH(git,
	AC_HELP_STRING([--with-git=[[[GIT]]]],[absolute path to git executable]),
	[GIT="$withval"])
AC_CHECK_PROG(GIT, git, git)
test -z "$GIT" && AC_MSG_WARN([git not found; mruby source must be provided manually])

AC_PROG_INSTALL

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
