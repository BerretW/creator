local Prompt = nil
local promptGroup = GetRandomIntInRange(0, 0xffffff)

local function prompt()
    Citizen.CreateThread(function()
        local str = "Nechat se ošetřit"
        local wait = 0
        Prompt = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(Prompt, 0x760A9C6F)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(Prompt, str)
        PromptSetEnabled(Prompt, true)
        PromptSetVisible(Prompt, true)
        PromptSetHoldMode(Prompt, true)
        PromptSetGroup(Prompt, promptGroup)
        PromptRegisterEnd(Prompt)
    end)
end

function sendChatMessage(prefix, message)
    -- Přizpůsob tuto funkci dle svého serverového frameworku
    -- Níže je uveden příklad pro běžný chat systém
    TriggerEvent('chat:addMessage', {
        color = {173, 217, 255}, -- Bílá barva textu
        multiline = true,
        args = {prefix, message}
    })
end

function startMedicalProcedure1899(patient)
    -- Definice více scénářů
    local scenarios = { -----------------------------------------------------------------------------
    -- SCÉNÁŘ 1 (cynický doktor)
    -----------------------------------------------------------------------------
    function(patient)
        exports["aprts_3dme"]:medo(
            "Doktor vstupuje do skromné ordinace a s jemným pohrdáním koukne na bezvědomého pacienta.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Zdravím, " .. patient ..
            ". Vypadá, že sis zadělal na pěknou polízanici. Zkusím tě teda nezabít.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor rozloží zastaralé nástroje na stole a přehlédne je křivým úsměvem.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Skalpely, pinzety, staré tonikum... To by mohlo stačit, když se nebudeš moc cukat.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor přikládá poslechový válec k hrudi pacienta a kontroluje puls.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Puls slabý, ale ještě dýcháš. Možná z tebe ještě něco bude.")
        Wait(10000)

        exports["aprts_3dme"]:medo(
            "Doktor vytahuje skleněnou masku napojenou na ruční měch a přidržuje ji u pacientova obličeje.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Třeba trochu vzduchu dokáže zázraky. Anebo taky ne.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor vyndává hořké tonikum a naklání ho k pacientovým rtům.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Na, vypij to. Sice nic moc, ale aspoň budeš mít čím v žaludku míchat.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor odkládá nástroje zpět a nadechne se poněkud otráveně.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Hotovo. Teď si počkáme, co nám prozradí ta zpropadená krev.")
        Wait(10000)
    end, -----------------------------------------------------------------------------
    -- SCÉNÁŘ 2 (cynický doktor)
    -----------------------------------------------------------------------------
    function(patient)
        exports["aprts_3dme"]:medo(
            "Doktor vkročí do malé dřevěné ordinace a zhodnotí pacienta rychlým, nevrlým pohledem.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Tak se podíváme, " .. patient ..
            ". Máš pocit, že tě něco sejme? Uvidíme, jestli se pleteš.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor vytahuje poslechový válec z kufříku a přikládá jej k hrudi pacienta.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Slyším slabé ozvy. No, aspoň něco. Tak to třeba nebude na funus.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor změří tlak zastaralým ručním měřičem.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Nízký, ale pořád lepší, než kdybys byl už po smrti. Snad máme ještě čas.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor mává lahvičkou čpavku a přibližuje ji k pacientovu nosu.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Čpavek. O nic příjemnější než politický projev, ale probouzí spolehlivě.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor nakapává hořkou tinkturu do úst pacienta.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Je to odporné, " .. patient .. ", ale aspoň se vzpamatuješ, jestli máš proč.")
        Wait(10000)

        exports["aprts_3dme"]:medo(
            "Doktor otírá nástroje hadříkem s karbolovou kyselinou a pomalu je skládá zpět.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Chvilku si oddechnem. Pak mrknem na tu krev, třeba budeme mít i štěstí.")
        Wait(10000)
    end, -----------------------------------------------------------------------------
    -- SCÉNÁŘ 3 (cynický doktor)
    -----------------------------------------------------------------------------
    function(patient)
        exports["aprts_3dme"]:medo(
            "Doktor si otírá ruce v misce s dezinfekcí a kritickým pohledem zhodnotí stav pacienta.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Tak jo, " .. patient .. ". Nevypadáš zrovna čile. Uvidíme, jestli z tebe něco bude.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor přiloží prsty na krční tepnu a zkusí nahmatat zbytky života.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Tlukot slabý, ale přece. Aspoň nemusím psát úmrtní list hned teď.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor vyndává starou injekční stříkačku a plní ji povzbuzující směsí.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Tahle speciálka buď postaví na nohy, nebo je konec. Sám jsem zvědav.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor vpichuje injekci pacientovi do paže a čeká na reakci.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Tak se ukaž, " .. patient .. ". Buď se probereš, nebo budu mít o čem psát paměti.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor bere čistý obvaz a zlehka obvazuje pacientova poranění.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Zvenku z tebe nic nevypadává, to je pokrok. Teď jen doufat, že uvnitř držíš pohromadě.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor odnáší stříkačku bokem a uklízí chirurgické nástroje.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Nedělej mi ostudu a přežij to. Možná se aspoň něco naučím o pokrocích v medicíně.")
        Wait(10000)
    end, -----------------------------------------------------------------------------
    -- SCÉNÁŘ 4 (rozverný doktor s irským přízvukem)
    -----------------------------------------------------------------------------
    function(patient)
        exports["aprts_3dme"]:medo("Doktor se vřítí do ordinace s typickou irskou energií a širokým úsměvem.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Ach, " .. patient .. ", tohle je slušná polízanice. Ale neboj, poradím si, to se vsadím.")
        Wait(10000)

        exports["aprts_3dme"]:medo(
            "Doktor vytahuje malý poslechový válec a vesele si prozpěvuje při měření pulsu.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Slyším tep, i když slabý. Pořád lepší než hrobové ticho, že?")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor jemně zatřese ramenem pacienta a snaží se ho trochu probrat.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Haló, " .. patient .. ", ne že mi tu usneš navěky. Ještě mám spoustu věcí na práci.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor vytahuje čpavek a dává ho opatrně pod nos pacienta.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Já vím, čpavek není jako irská whiskey, ale dokáže divy, věř mi.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor nabídne trochu hořkého odvaru a usmívá se nad svým optimismem.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Vypij to, " .. patient .. ". A pak třeba někdy ochutnáš lepší mok než tohle.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor si odfoukne a obrátí se k menšímu stolku s mikroskopem.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Než prohlédnu krev, odpočiň si trochu. S trochou štěstí budeš brzy zase na nohou.")
        Wait(10000)
    end, -----------------------------------------------------------------------------
    -- SCÉNÁŘ 5 (vznešený doktor s francouzským přízvukem)
    -----------------------------------------------------------------------------
    function(patient)
        exports["aprts_3dme"]:medo(
            "Doktor s vybraným chováním vstoupí do ordinace a zlehka nakloní hlavu k pacientovi.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Ah, " .. patient .. ", c'est tragique, oui? Ale já vám pomohu, to si pište.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor ladně zvedá poslechový válec a naslouchá s elegancí baletního mistra.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Srdce sice nespěchá, ale bije. Doufám, že to není jeho poslední tanec.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor jemně připravuje dýchací masku a přidržuje ji pacientovi u obličeje.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Trocha kyslíku, mon ami. Snad rozproudí krev, ano?")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor vyndává drobnou lahvičku s hořkým elixírem a zakroutí nad ní nos.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Oui, ta vůně je urážkou pro můj vytříbený vkus, ale prosím, polkněte to.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor si odloží nástroje stranou a lehce si otře ruce vonnou esencí.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Necháme to chvíli působit. Pak se podívám na vaši krev, cher patient.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor se pousměje, jako by byl hostitelem na noblesním večírku.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Tak, prozatím to bude stačit. Zatím se uvolněte.")
        Wait(10000)
    end, -----------------------------------------------------------------------------
    -- SCÉNÁŘ 6 (seriózní anglický lékař - stoický a metodický)
    -----------------------------------------------------------------------------
    function(patient)
        exports["aprts_3dme"]:medo(
            "Doktor vkročí tiše do ordinace, narovná si límeček a pohlédne na bezvědomého pacienta.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            patient .. ", nevypadáte dobře. Ovšem panika nepomůže, držme se postupu.")
        Wait(10000)

        exports["aprts_3dme"]:medo(
            "Doktor připravuje poslechový válec a bez zbytečných řečí kontroluje srdeční ozvy.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Srdeční rytmus je slabý, ale zatím konzistentní. Využijme každou vteřinu.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor vyndává tlakoměr a pečlivě zaznamenává údaje do zápisníku.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Tlak je nízký. Musíme jednat rozhodně, avšak zůstat v klidu.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor se sklání k pacientovi a tiše ho povzbuzuje, aby se probral.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Slyšíte mě, " .. patient .. "? Zkuste reagovat, třeba jen pohnutím prstu.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor jemně aplikuje roztok z malého flakónu přímo do úst pacienta.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Tento přípravek má podpořit stabilizaci. Snad je to správný krok.")
        Wait(10000)

        exports["aprts_3dme"]:medo(
            "Doktor si důkladně opláchne ruce dezinfekcí a odkládá flakóny zpět do kufříku.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Necháme čas, aby zapracoval ve váš prospěch. Ještě prověřím vzorky krve.")
        Wait(10000)
    end, -- SCÉNÁŘ 7 (sprostý doktor z Rakouska-Uherska, mluví v Hantecu)
    function(patient)
        exports["aprts_3dme"]:medo(
            "Doktor rázuje do omšelé ordinace, s brbláním nakopne starou stoličku a koukne na pacienta.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Ty kráso, " .. patient ..
            ", co si to jako vyváděl? Vypadáš jak šraňek po špatné štrece.")
        Wait(10000)

        exports["aprts_3dme"]:medo(
            "Doktor nahmatává tep pacienta, přitom se nervózně ohlíží po zaprášeném lékařském kufříku.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Né že mi tu chcípneš, bo mám ešče hafo šichty. Drž se, cype.")
        Wait(10000)

        exports["aprts_3dme"]:medo(
            "Doktor hrubě vyhrábne nějaké nástroje z kufříku a roztřesenou rukou hledá dezinfekci.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Tádydádá, karho to sprcalo. Ešče sem neviděl, aby se někdo tak rozmázl. Drž zobák a nehýbej sa!")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor vytahuje čpavek, strčí ho pacientovi pod nos a netrpělivě čeká.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "No, šňupni si, než s tebú mrcasnu. Není to samospas, ale betálné to ešče bejt móže.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor uchopí lahvičku s hořkým tonikem a přiloží ji k ústům pacienta.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Vem si to, kovbojú. Třeba ti to neroztrhá pajšl, ale nečekej, že to bude jak v cajku.")
        Wait(10000)

        exports["aprts_3dme"]:medo(
            "Doktor odkládá lékařské nástroje a dává si ruce v bok, nevrle přitom odfrkne.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Budem kukat, co vyleze z té tvé krve. Aspoň ať vím, jestli sem tu dneska neztrácel čas.")
        Wait(10000)
    end, -- SCÉNÁŘ 8 (východňár ze Slovenska, mluví východoslovenském dialektu)
    function(patient)
        exports["aprts_3dme"]:medo(
            "Doktor vkráča do chudobnej ordinácie, mrskne plášť cez stoličku a valí pohľad na pacienta.")
        Wait(1000)
        sendChatMessage("Doktor: ", "No, " .. patient ..
            ", co ši to vymyslel? Špaky ci trčia z kapce alebo co? Vyzeráš, jak by ťa parný valec prešól.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor mrzuto chytí pacientovo zápästie a skúša nahmatať pulz.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Ha! Ešči žiješ, chvála bohu. Ta ne, že mi zdochneš, bo ja mam ešte aj iné roboty.")
        Wait(10000)

        exports["aprts_3dme"]:medo(
            "Doktor vytiahne kahanec s dezinfekciou, načapá štetcom a bezohľadne natrie ranu.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Nezervaj sa, bo ťa švihnem! Šče ci tam dačo nakvapkám, to bude ešče fajne páliť.")
        Wait(10000)

        exports["aprts_3dme"]:medo(
            "Doktor vytiahne zaprášenú fľašku s horkým elixírom a tlačí ju pacientovi k perám.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Šup-šup, chlóp. Žadne frfľanie, lebo ti dám ešče horšie svinstvo. No pij a sťažuj sa potom.")
        Wait(10000)

        exports["aprts_3dme"]:medo(
            "Doktor vytasí prastaru striekačku s kovovou ihlou a sleduje pacienta skúmavým pohľadom.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Ešči pichnem takú zmes do cibu, bo neviem, či ťa to zachráni, ale lepšie, jak by si mal skapac.")
        Wait(10000)

        exports["aprts_3dme"]:medo("Doktor zhodí ihlu do misky a otrávene si obtrie ruky do zástery.")
        Wait(1000)
        sendChatMessage("Doktor: ",
            "Teraz kuknem na tú tvoju krv. Dúfam, že tam nenájdem ešče väčšiu galibu, inak šeci pôjdeme do rici.")
        Wait(10000)
    end,
    function(patient)
        exports["aprts_3dme"]:medo("Doktor se nervózně zamotá do ordinace a mává starými nástroji kolem sebe, zatímco se pokouší vzpomenout, co má dělat dál.")
        Wait(1000)
        sendChatMessage("Doktor: ", "P-p-p-přivítám vás, " .. patient .. ". D-d-dnes... hmm, co jsme dělali? Aha, vyšetřování!")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor pomalu otevírá kufřík, ale jeho pohyby jsou nejisté a nástroje se mu často sklouzávají.")
        Wait(1000)
        sendChatMessage("Doktor: ", "T-t-tady máme... ehm... skalpel? No, to by mohlo... ehm... něco udělat.")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor se pokouší přiložit poslechový válec k pacientově hrudi, ale najednou zastaví a zapomene, proč to dělá.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Hm... proč jsem to vlastně... Ach, ano! Pulz! Musím... ehm... poslouchat!")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor vytahuje dýchací masku, ale během toho se zamotá do jejího používání a chvíli ztratí orientaci.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Masku... ano, dýchání! Trocha vzduchu, snad pomůže... No, co jsem měl říct dál?")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor vyndává lahvičku s tonikem, ale na moment zapomene, kam ji chce dát.")
        Wait(1000)
        sendChatMessage("Doktor: ", "T-tonikum... ano, to je to! Vypij to, " .. patient .. ". Doufám, že... ehm... pomůže.")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor se snaží ukládat nástroje zpět do kufříku, ale opět zapomene, co dělá.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Hotovo... nebo možná ne? Každopádně, čekáme na krevní výsledky.")
        Wait(10000)
    end,
    function(patient)
        exports["aprts_3dme"]:medo("Doktor vrávoravě vejde do ordinace, rozhlíží se po stole a vypadá zmateně, jako by hledal něco, co tam nikdy nebylo.")
        Wait(1000)
        sendChatMessage("Doktor: ", "E-e-ehm... Z-zo... zdravím, " .. patient .. ". M-myslím, že tu máme nějaké... ee... vyšetření?")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor se pokusí otevřít starý kufřík, ale nástroje mu vypadávají z rukou a chřestí na podlaze.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Tohle... t-tady... je skalpel? Nebo, moment, co jsem to... Ajaj, zapomněl jsem, co jsem chtěl.")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor už-už přikládá poslechový válec k pacientově hrudi, ale znenadání se zarazí, jako by ztratil nit.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Heh... c-co jsem to... no jasně, pulz! M-musím poslouchat pulz, že?")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor vytahuje z kufříku dýchací masku, na chvíli ji otáčí v rukách a zkoumá, jak ji vlastně nasadit.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Tohle... j-jo, to je pro dýchání. A-a... kam se to dává? Jo! Dám to sem, snad pomůže.")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor vytahuje malou lahvičku s tonikem a nejistě ji drží, chvíli netuší, co s ní udělat.")
        Wait(1000)
        sendChatMessage("Doktor: ", "T-tonik! P-prosím... vypijte to, " .. patient .. ". S-snad to není ten špatný lektvar.")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor se rozhlíží kolem, pokouší se uklidit nástroje zpátky do kufříku, ale zdá se, že už zapomněl, kde je kufřík.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Ehm... H-hotovo? N-nebo co jsem... Jo! Musíme počkat na krev... myslím. Asi jo.")
        Wait(10000)
    end,
    function(patient)
        exports["aprts_3dme"]:medo("Doktor vstupuje do ordinace s výrazným sebevědomím, pokyvuje rukama a usmívá se širokým úsměvem.")
        Wait(1000)
        sendChatMessage("Doktor: ", "No dobře, " .. patient .. ", jste tady u toho nejlepšího doktora v celém státě. To si můžete být jisti.")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor pomalu rozkládá nástroje na stole s jistotou a elegancí.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Tady máme ty nejlepší skalpely a pinzety, pravděpodobně nejlepší, co můžete najít. Nikdo nepřinese lepší nástroje než já.")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor přikládá poslechový válec k pacientově hrudi a naslouchá s úsměvem.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Vidím, že vaše srdce bije skvěle. To je fantastické. Pravděpodobně nejlepší srdce, jaké jsem kdy slyšel.")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor připravuje dýchací masku a přikládá ji pacientovi s jistotou.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Tato maska je revoluční, opravdu revoluční. Trocha vzduchu a brzy budete zpět na nohou. Věříte mi, to funguje.")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor vytahuje lahvičku s tonikem a elegantně ji drží před pacientem.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Tady je naše nejnovější tonikum. Je to nejlepší, opravdu nejlepší, a vy to vypijete a budete se cítit úžasně.")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor ukládá nástroje zpět do kufříku s lehkým úsměvem.")
        Wait(1000)
        sendChatMessage("Doktor: ", "Hotovo. Teď necháme krev analyzovat ty nejlepší laboratoře. Bude to úžasné, můžete si být jisti.")
        Wait(10000)
    end,
    function(patient)
        exports["aprts_3dme"]:medo("Doktor vejde do ordinace jako stín. Zkroušeně shlíží na pacienta, jako by se už dávno smířil s nejhorším.")
        Wait(1000)
        sendChatMessage("doktor říká", "Dobrý den, " .. patient .. "... Asi je to stejně zbytečné, nikdo nám nepomůže.")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor se neochotně sklání ke svému kufříku, ale při každém pohybu vypadá, že by nejraději nechal vše být.")
        Wait(1000)
        sendChatMessage("doktor říká", "Tady nějaké nástroje... ale k čemu to? Jen ztrácíme čas.")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor opatrně pokládá prsty na tepnu pacienta, avšak jeho výraz napovídá, že ani tato kontrola ho netěší.")
        Wait(1000)
        sendChatMessage("doktor říká", "Puls... no, ještě žijete, ale po pravdě je to stejně všechno jen odklad konce.")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor zkouší připravit dýchací pomůcku, ale při pohledu na ni jen trpce vzdychne.")
        Wait(1000)
        sendChatMessage("doktor říká", "Vzduch... hm, no snad to trošku oddálí nevyhnutelné. Nevím, proč se snažíme.")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor vytahuje tonikum, ale jeho pohled se přitom ztrácí v prázdnu.")
        Wait(1000)
        sendChatMessage("doktor říká", "Vypijte to, " .. patient .. ". I když pochybuju, že nám to nějak zlepší vyhlídky.")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor zaklapne kufřík s neochotnou pečlivostí, jako by si přál, aby už bylo po všem.")
        Wait(1000)
        sendChatMessage("doktor říká", "No... asi je hotovo. Ale co na tom sejde? Stejně se všechno jednou rozpadne na prach.")
        Wait(10000)
    end,
    function(patient)
        exports["aprts_3dme"]:medo("Doktor vtrhne do ordinace s natěšeným úsměvem, jako by právě vyhrál v loterii, a prudce se zastaví u pacienta.")
        Wait(1000)
        sendChatMessage("doktor říká", "Zdravíčko, " .. patient .. "! Páni, koukám, tady něco plandá, že? Žádný strach, můžem to přece jednoduše uříznout, no ne?")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor si prohlédne kufřík plný nástrojů a nadšeně mává skalpelem, jako by to byla hračka.")
        Wait(1000)
        sendChatMessage("doktor říká", "Hihi, co kdybychom rovnou přidělali něco navíc? Taková drobná úprava, aby to líp sedělo.")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor vesele přiloží poslechový válec k pacientově hrudi, přitom se nepřestává uchechtávat.")
        Wait(1000)
        sendChatMessage("doktor říká", "Srdíčko běží, to je krása! No, ještě pár zásahů a budete jako nový výstavní kousek.")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor vytahuje dýchací masku, ale předtím ji spiklenecky ukazuje pacientovi, jako by šlo o zábavný kostým.")
        Wait(1000)
        sendChatMessage("doktor říká", "Tuhle masku vám nasadím a hned se budem cítit líp, že? Jako bychom hráli divadlo, co říkáte?")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor vyndává lahvičku s tonikem, teatrálně ji předvádí a ťuká prstem o sklo, aby to cinkalo.")
        Wait(1000)
        sendChatMessage("doktor říká", "Tak tady to je, zázračnej lektvar! Stačí polknout a máte energii na další kaskadérské kousky, haha!")
        Wait(10000)
    
        exports["aprts_3dme"]:medo("Doktor si s velkou vervou uklízí nástroje, nadšeně přitom pohazuje skalpelem.")
        Wait(1000)
        sendChatMessage("doktor říká", "Tak, to by bylo! Mám chuť něco vyoperovat navíc, ale asi se budu krotit. Prozatím.")
        Wait(10000)
    end,function(patient)
        exports["aprts_3dme"]:medo("Doktor vklouzne do ordinace lehce našlapuje, jako by korzoval po přehlídkovém molu. Působí sebejistě, ale v očích je vidět nejistotu.")
        Wait(1000)
        sendChatMessage("doktor říká", "Ááále, dobrý den, " .. patient .. "! Dneska si dáme takovou malou... ehm... prohlídku, ano?")
        Wait(10000)
        
        exports["aprts_3dme"]:medo("Doktor si uhladí neviditelnou záhyb na vestě a ostražitě koukne kolem, jako by se bál, že ho někdo přistihne, jak se až moc stará o svůj outfit.")
        Wait(1000)
        sendChatMessage("doktor říká", "To je tak rušné odpoledne, že mi z toho srdíčko div nevyletí, ale pšt... nikdo to nemusí vědět, že? P-prostě to nechme mezi námi, milý " .. patient .. ".")
        Wait(10000)
        
        exports["aprts_3dme"]:medo("Doktor vytahuje skalpel z kufříku, ale drží ho tak opatrně a až roztomile, jako by byl z křišťálu, přitom se nervózně usmívá.")
        Wait(1000)
        sendChatMessage("doktor říká", "No páni, tahle ostrá věcička... Hihi, trochu mě děsí, ale... vím přesně, co s ní dělat! Tedy... ehm, radši se nechte překvapit.")
        Wait(10000)
        
        exports["aprts_3dme"]:medo("Doktor nakloní hlavu a pozorně se zadívá na ránu, pak teatrálně vydechne, jako by hodnotil nové šaty.")
        Wait(1000)
        sendChatMessage("doktor říká", "Ou, tady to trochu... no... plandá. Ale slibuji, já to zvládnu, " .. patient .. "! Moje ruce jsou jemné a přesné, však uvidíte.")
        Wait(10000)
        
        exports["aprts_3dme"]:medo("Doktor se nahne blíž, aby poslouchal dech pacienta, přičemž skoro dramaticky otočí zápěstím a zavlní se, jakoby tančil.")
        Wait(1000)
        sendChatMessage("doktor říká", "Náádech, výýdech. Ach, vlastně by se mi líbilo, kdybychom si z toho udělali malý duet... Ale pšt! To... to není důležité.")
        Wait(10000)
        
        exports["aprts_3dme"]:medo("Doktor vytahuje lahvičku s dezinfekcí, mrká na pacienta a zlehka si přičichne, jako by to byla parfémová esence.")
        Wait(1000)
        sendChatMessage("doktor říká", "Hmm, voní to jako... e-elegantní kapky slz radosti. Trochu to zaštípe, ale co se dá dělat, musíme udržet styl, že?")
        Wait(10000)
        
        exports["aprts_3dme"]:medo("Doktor finišuje, snaží se uklidit nástroje zpět do kufříku. Přitom se několikrát rozhlédne, jestli ho někdo nepozoruje.")
        Wait(1000)
        sendChatMessage("doktor říká", "Tak, je to hotové... Skvěle jsme to zvládli, i když nevím, jestli mě nepřeválcují drby, jak moc mě to vlastně bavilo! Ale pššt.")
        Wait(10000)
    end}

    -- Náhodný výběr scénáře
    local selectedScenario = scenarios[math.random(#scenarios)]
    selectedScenario(patient)

    -- Simulace výsledků testů (mikroskopické vyšetření krve apod.)
    local bloodCondition = math.random(1, 2) -- 1 pro normální, 2 pro abnormální

    if bloodCondition == 1 then
        exports["aprts_3dme"]:medo("Doktor nakoukne do primitivního mikroskopu a zakroutí hlavou.")
        sendChatMessage("Doktor: ", "Krevní obraz docela ujde, " .. patient .. ". Možná se z toho vyhrabete.")
    else
        exports["aprts_3dme"]:medo("Doktor se zamračí na sklíčko v mikroskopu a něco načmárá na kus papíru.")
        sendChatMessage("Doktor: ",
            "No, " .. patient .. ", vypadá to všelijak. Budu vás muset ještě chvíli hlídat.")
    end
    Wait(10000)

    -- Dokončení procedury
    exports["aprts_3dme"]:medo(
        "Doktor odkládá dezinfekci a ustupuje od lůžka, ukládaje nástroje zpět do kufříku a poplácá pacienta po rameni.")
    sendChatMessage("Doktor: ",
        "Tímto končím vyšetření. Uvidíme, zda se " .. patient .. " probere. Držte se.")
    Wait(10000)
end

Citizen.CreateThread(function()
    prompt()
    while true do
        local pause = 1000

        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        for _, doctor in pairs(Config.NPC) do
            local distance =
                GetDistanceBetweenCoords(playerPos, doctor.coords.x, doctor.coords.y, doctor.coords.z, true)
            if distance < 2.0 and IsEntityDead(playerPed) then
                pause = 0
                local name = CreateVarString(10, 'LITERAL_STRING',
                    tostring(doctor.name) .. " - " .. tostring(doctor.price) .. "$")
                PromptSetActiveGroupThisFrame(promptGroup, name)
                if PromptHasHoldModeCompleted(Prompt) then

                    local playerName = LocalPlayer.state.Character.FirstName .. " " ..
                                           LocalPlayer.state.Character.LastName
                    startMedicalProcedure1899(playerName)
                    notify("Byl jsi ošetřen")
                    TriggerEvent("aprts_medicalAtention:Client:reviveME")
                    TriggerServerEvent("aprts_medicalAtention:Server:takeMoney", doctor.price)
                    Citizen.Wait(1000)
                end
            end
        end
        Citizen.Wait(pause)
    end
end)
