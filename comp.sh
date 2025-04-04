#!/bin/bash

test=$1

# Nettoyage précédent
rm -f *.o *.cf *.vcd

# Étape 1 : Analyse de tous les fichiers VHDL
echo "[1/3] Analyse des fichiers VHDL..."
ghdl -a mem.vhd
ghdl -a reg_bank.vhd
ghdl -a combi.vhd
ghdl -a etages.vhd
ghdl -a proc.vhd
ghdl -a $test.vhd

# Facultatif : ajouter d'autres fichiers si besoin
# ghdl -a autre_fichier.vhd

# Étape 2 : Élaboration du banc de test
echo "[2/3] Élaboration du testbench..."
ghdl -e $test

# Étape 3 : Simulation avec génération de trace VCD
echo "[3/3] Simulation..."
ghdl -r $test --wave=sim.ghw --stop-time=200ns

# Lancement de GTKWave
echo "Lancement de GTKWave..."
gtkwave sim.ghw &
