# Objective: convex quadratic 
# Constraints: linear 
param 	cases;		# liczba probek
set 	SCENARIOS = { 1..cases}; # liczba "okresow czasu" rowna liczbie probek
set 	PRODUCTS;   			# zestaw produktow
set 	MONTHS ordered;		# zestaw miesiecy dla ktorych przewidujemy
set 	TOOLS;				# zestaw narzedzi potrzebnych do produkcji

param m0;	# minimalny oczekiwany zysk

# wspolczynnik awersji do ryzyka;
param lambda;

# liczba godzin pracy przedsiebiorstwa w miesiacu;
param factoryTime;

# cena skladowania jednej sztuki dowolnego produktu w magazynie
param storeFare;

# czasy produkcji produktow w zaleznosci od narzedzi
param productionTime { n in TOOLS, j in PRODUCTS};

# ograniczenia rynkowe na liczbe sprzedawanych produktow
param MarketLimitation { m in MONTHS, j in PRODUCTS};

# liczba narzedzi
param toolsNumber { n in TOOLS};

# macierz dochodow ze sprzedazy produktow
param R {SCENARIOS,PRODUCTS};

# realizacja R_j w czasie T
param rt {t in SCENARIOS, j in PRODUCTS}
	= R[t,j];

param r {m in MONTHS, j in PRODUCTS} 
	= 1/card(SCENARIOS) * sum {t in SCENARIOS} rt[t, j];

param A {t in SCENARIOS, m in MONTHS, j in PRODUCTS}
	= rt[t, j] - r[m,j];

# ZMIENNA DECYZYJNA
# ile produktow na sprzedaz
var x {m in MONTHS, j in PRODUCTS} integer; 

# ile produktow do przechowania
var y{ m in MONTHS, j in PRODUCTS} integer;

# ile produktow do sprzedazy z magazynu
var z{ m in MONTHS, j in PRODUCTS} integer;

# zmienna pomocnicza
var abs_sum {t in SCENARIOS} integer;

var risk =
	1/card(SCENARIOS) * sum {t in SCENARIOS } abs_sum[t];

var profit =
	sum { m in MONTHS, j in PRODUCTS } 
	r[m,j]*(
		x[m,j] 				# bezposrednia sprzedaz
		+z[m,j] 			# sprzedaz z magazynu
		- storeFare * ( 	# koszt magazynowania
			sum {k in MONTHS : ord(k) < ord(m) } ( y[k, j] - z[k, j]))
		);

# FUNKCJA CELU
minimize minimizedRisk:
	risk;

#maximize maximizedProfit:
#	profit;

# OGRANICZENIA

# abs to linear
subject to lower_bound {t in SCENARIOS}:
	sum{m in MONTHS, j in PRODUCTS} A[t,m,j]*x[m,j] >= - abs_sum[t];

subject to upper_bound {t in SCENARIOS}:
	sum{m in MONTHS, j in PRODUCTS} A[t,m,j]*x[m,j] <= abs_sum[t];

# minimalna wartość przychodu
subject to min_profit :
	profit >= m0;

# nieujemna sprzedaz
subject to non_negative_sell {m in MONTHS, j in PRODUCTS}:
	x[m,j] >= 0;

# nieujemne branie produktow z magazynu
subject to non_negative_take {m in MONTHS, j in PRODUCTS}:
	z[m, j] >= 0;

# nieujemne trzymanie w magazynie
subject to non_negative_store {m in MONTHS, j in PRODUCTS}:
	y[m, j] >= 0;

# nie mozemy wziac wiecej niz jest w magazynie
subject to max_take {m in MONTHS, j in PRODUCTS}:
	z[m, j] <= sum { k in MONTHS : ord(k) < ord (m)} (y[k, j] - z[k, j]);

# liczba przechowywanego dow. rodzaju produktu nie przekracza 200
# zakladam ze sprzedaje z poprzednich miesiecy na poczatku miesiaca
# na koniec miesiaca dodaje produkty do magazynu
subject to max_store {j in PRODUCTS, m in MONTHS}:
	200 >= sum { k in MONTHS : ord(k) <= ord(m) } ( y[k, j] - z[k, j]);

# na koniec potrzebujemy po 50 sztuk zapasu towarow
subject to end_store {j in PRODUCTS}:
	y['Mar', j] = 50;

# liczba sprzedawanych produktow mniejsza niz ograniczenia rynkowe liczby sprzedazy
subject to market_limit {j in PRODUCTS, m in MONTHS}:
	x[m, j] + z[m, j] <= MarketLimitation[m, j];
#	x[m, j] <= MarketLimitation[m, j];

# czas produkcji kazdego produktu w kazdym miesiacu nie przekracza czasu pracy przedsiebiorstwa
# 384 = 24 dni robocze * 2 zmiany * 8h
subject to factory_time {m in MONTHS, j in PRODUCTS}:
	sum{ n in TOOLS } ((x[m, j] + y[m, j]) * productionTime[n, j]) <= factoryTime;

# czasy wykorzystania narzedzi do produkcji nie przekracza czasu pracy przedsiebiorstwa
subject to tools_time {m in MONTHS, n in TOOLS}:
	sum { j in PRODUCTS } ((x[m, j] + y[m, j]) * productionTime[n, j]) <= toolsNumber[n]*factoryTime;


