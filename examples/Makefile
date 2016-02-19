include ../minc.mk

default: demo

$(ABCDIR)/libabc.a:
	$(MAKE) -C $(ABCDIR) -f Makefile

# have a direct executable version (exec) and an sql-based version (sql)
abc_simulator_%.o: main_%.cpp $(ABCDIR)/libabc.a
	$(CPP) $(CFLAGS) -I$(GSL_INC) $(ABC_INC) $< -o $@ $(ABC_LIB) $(GSL_LIB)

dice_game.o: dice_game.cpp
	$(CPP) $(CFLAGS) -I$(GSL_INC) $< -o $@ $(GSL_LIB)

clean:
	$(MAKE) -C $(ABCDIR) clean
	rm -f *.o
	rm -f *.sqlite

demo: abc_simulator_sql.o abc_config_sql.json
	./$^ --process
	./$^ --simulate -n 1000
