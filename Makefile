docker: git_version
	${cc_local} -o ${NAME} -I. ${SOURCES} ${FLAGS} -lrt -O2 -pipe -g0 -m64 -DNOLIMIT
