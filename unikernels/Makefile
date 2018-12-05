
.PHONY: all unix ukvm inventory_unix inventory_ukvm authentication_unix authentication_ukvm front_unix front_ukvm clean
all: unix

unix: front_unix inventory_unix authentication_unix

ukvm: front_ukvm inventory_ukvm authentication_ukvm

inventory_unix:
	mirage configure -f inventory/config.ml -t unix
	make -C inventory

inventory_ukvm:
	mirage configure -f inventory/config.ml -t ukvm
	make -C inventory

authentication_unix:
	mirage configure -f authentication/config.ml -t unix
	make -C authentication

authentication_ukvm:
	mirage configure -f authentication/config.ml -t ukvm
	make -C authentication

front_unix:
	mirage configure -f front/config.ml -t unix
	make -C front

front_ukvm:
	mirage configure -f front/config.ml -t ukvm
	make -C front

clean:
	-make -C front $@
	-make -C inventory $@
	-make -C authentication $@
