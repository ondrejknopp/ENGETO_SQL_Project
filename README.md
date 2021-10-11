# ENGETO_SQL_Project
First project in Data analysis course by Engeto Academy

Cílem projektu bylo vytvoření tabulky dle následujícího zadání:

"Dobrý den,

snažím se určit faktory, které ovlivňují rychlost šíření koronaviru na úrovni jednotlivých států. Chtěl bych Vás, coby datového analytika, požádat o pomoc s přípravou dat, která potom budu statisticky zpracovávat. Prosím Vás o dodání dat podle požadavků sepsaných níže.

Výsledná data budou panelová, klíče budou stát (country) a den (date). Budu vyhodnocovat model, který bude vysvětlovat denní nárůsty nakažených v jednotlivých zemích. Samotné počty nakažených mi nicméně nejsou nic platné - je potřeba vzít v úvahu také počty provedených testů a počet obyvatel daného státu. Z těchto tří proměnných je potom možné vytvořit vhodnou vysvětlovanou proměnnou. Denní počty nakažených chci vysvětlovat pomocí proměnných několika typů. Každý sloupec v tabulce bude představovat jednu proměnnou. Chceme získat následující sloupce:

Časové proměnné
binární proměnná pro víkend / pracovní den
roční období daného dne (zakódujte prosím jako 0 až 3)
Proměnné specifické pro daný stát
hustota zalidnění - ve státech s vyšší hustotou zalidnění se nákaza může šířit rychleji
HDP na obyvatele - použijeme jako indikátor ekonomické vyspělosti státu
GINI koeficient - má majetková nerovnost vliv na šíření koronaviru?
dětská úmrtnost - použijeme jako indikátor kvality zdravotnictví
medián věku obyvatel v roce 2018 - státy se starším obyvatelstvem mohou být postiženy více
podíly jednotlivých náboženství - použijeme jako proxy proměnnou pro kulturní specifika. Pro každé náboženství v daném státě bych chtěl procentní podíl jeho příslušníků na celkovém obyvatelstvu
rozdíl mezi očekávanou dobou dožití v roce 1965 a v roce 2015 - státy, ve kterých proběhl rychlý rozvoj mohou reagovat jinak než země, které jsou vyspělé už delší dobu
Počasí (ovlivňuje chování lidí a také schopnost šíření viru)
průměrná denní (nikoli noční!) teplota
počet hodin v daném dni, kdy byly srážky nenulové
maximální síla větru v nárazech během dne"
