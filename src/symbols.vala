/*
 * This file is part of LaTeXila.
 *
 * Copyright © 2010 Sébastien Wilmet
 *
 * LaTeXila is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * LaTeXila is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with LaTeXila.  If not, see <http://www.gnu.org/licenses/>.
 */

using Gtk;

public class Symbols : VBox
{
    struct SymbolInfo
    {
        public string filename;
        public string latex_command;
        public string package_required;
    }

    struct CategoryInfo
    {
        public string name;
        public string icon;
    }

    enum SymbolColumn
    {
        PIXBUF,
        COMMAND,
        TOOLTIP,
        N_COLUMNS
    }

    enum CategoryColumn
    {
        ICON,
        NAME,
        NUM,
        N_COLUMNS
    }

    private const CategoryInfo[] categories =
    {
        {N_("Greek"), Config.DATA_DIR + "/images/icons/symbol_greek.png"},
        // when we drink too much tequila we walk like this arrow...
        {N_("Arrows"), Config.DATA_DIR + "/images/icons/symbol_arrows.png"},
        {N_("Relations"), Config.DATA_DIR + "/images/icons/symbol_relations.png"},
        {N_("Operators"), Config.DATA_DIR + "/images/icons/symbol_operators.png"},
        {N_("Delimiters"), Config.DATA_DIR + "/images/icons/symbol_delimiters.png"},
        {N_("Misc math"), Config.DATA_DIR + "/images/icons/symbol_misc_math.png"},
        {N_("Misc text"), Config.DATA_DIR + "/images/icons/symbol_misc_text.png"}
    };

    private const SymbolInfo[] symbols_greek =
    {
        {Config.DATA_DIR + "/images/greek/01.png", "\\alpha", null},
        {Config.DATA_DIR + "/images/greek/02.png", "\\beta", null},
        {Config.DATA_DIR + "/images/greek/03.png", "\\gamma", null},
        {Config.DATA_DIR + "/images/greek/04.png", "\\delta", null},
        {Config.DATA_DIR + "/images/greek/05.png", "\\epsilon", null},
        {Config.DATA_DIR + "/images/greek/06.png", "\\varepsilon", null},
        {Config.DATA_DIR + "/images/greek/07.png", "\\zeta", null},
        {Config.DATA_DIR + "/images/greek/08.png", "\\eta", null},
        {Config.DATA_DIR + "/images/greek/09.png", "\\theta", null},
        {Config.DATA_DIR + "/images/greek/10.png", "\\vartheta", null},
        {Config.DATA_DIR + "/images/greek/11.png", "\\iota", null},
        {Config.DATA_DIR + "/images/greek/12.png", "\\kappa", null},
        {Config.DATA_DIR + "/images/greek/13.png", "\\lambda", null},
        {Config.DATA_DIR + "/images/greek/14.png", "\\mu", null},
        {Config.DATA_DIR + "/images/greek/15.png", "\\nu", null},
        {Config.DATA_DIR + "/images/greek/16.png", "\\xi", null},
        {Config.DATA_DIR + "/images/greek/17.png", "o", null},
        {Config.DATA_DIR + "/images/greek/18.png", "\\pi", null},
        {Config.DATA_DIR + "/images/greek/19.png", "\\varpi", null},
        {Config.DATA_DIR + "/images/greek/20.png", "\\rho", null},
        {Config.DATA_DIR + "/images/greek/21.png", "\\varrho", null},
        {Config.DATA_DIR + "/images/greek/22.png", "\\sigma", null},
        {Config.DATA_DIR + "/images/greek/23.png", "\\varsigma", null},
        {Config.DATA_DIR + "/images/greek/24.png", "\\tau", null},
        {Config.DATA_DIR + "/images/greek/25.png", "\\upsilon", null},
        {Config.DATA_DIR + "/images/greek/26.png", "\\phi", null},
        {Config.DATA_DIR + "/images/greek/27.png", "\\varphi", null},
        {Config.DATA_DIR + "/images/greek/28.png", "\\chi", null},
        {Config.DATA_DIR + "/images/greek/29.png", "\\psi", null},
        {Config.DATA_DIR + "/images/greek/30.png", "\\omega", null},
        {Config.DATA_DIR + "/images/greek/31.png", "A", null},
        {Config.DATA_DIR + "/images/greek/32.png", "B", null},
        {Config.DATA_DIR + "/images/greek/33.png", "\\Gamma", null},
        {Config.DATA_DIR + "/images/greek/34.png", "\\varGamma", "amsmath"},
        {Config.DATA_DIR + "/images/greek/35.png", "\\Delta", null},
        {Config.DATA_DIR + "/images/greek/36.png", "\\varDelta", "amsmath"},
        {Config.DATA_DIR + "/images/greek/37.png", "E", null},
        {Config.DATA_DIR + "/images/greek/38.png", "Z", null},
        {Config.DATA_DIR + "/images/greek/39.png", "H", null},
        {Config.DATA_DIR + "/images/greek/40.png", "\\Theta", null},
        {Config.DATA_DIR + "/images/greek/41.png", "\\varTheta", "amsmath"},
        {Config.DATA_DIR + "/images/greek/42.png", "I", null},
        {Config.DATA_DIR + "/images/greek/43.png", "K", null},
        {Config.DATA_DIR + "/images/greek/44.png", "\\Lambda", null},
        {Config.DATA_DIR + "/images/greek/45.png", "\\varLambda", "amsmath"},
        {Config.DATA_DIR + "/images/greek/46.png", "M", null},
        {Config.DATA_DIR + "/images/greek/47.png", "N", null},
        {Config.DATA_DIR + "/images/greek/48.png", "\\Xi", null},
        {Config.DATA_DIR + "/images/greek/49.png", "\\varXi", "amsmath"},
        {Config.DATA_DIR + "/images/greek/50.png", "O", null},
        {Config.DATA_DIR + "/images/greek/51.png", "\\Pi", null},
        {Config.DATA_DIR + "/images/greek/52.png", "\\varPi", "amsmath"},
        {Config.DATA_DIR + "/images/greek/53.png", "P", null},
        {Config.DATA_DIR + "/images/greek/54.png", "\\Sigma", null},
        {Config.DATA_DIR + "/images/greek/55.png", "\\varSigma", "amsmath"},
        {Config.DATA_DIR + "/images/greek/56.png", "T", null},
        {Config.DATA_DIR + "/images/greek/57.png", "\\Upsilon", null},
        {Config.DATA_DIR + "/images/greek/58.png", "\\varUpsilon", "amsmath"},
        {Config.DATA_DIR + "/images/greek/59.png", "\\Phi", null},
        {Config.DATA_DIR + "/images/greek/60.png", "\\varPhi", "amsmath"},
        {Config.DATA_DIR + "/images/greek/61.png", "X", null},
        {Config.DATA_DIR + "/images/greek/62.png", "\\Psi", null},
        {Config.DATA_DIR + "/images/greek/63.png", "\\varPsi", "amsmath"},
        {Config.DATA_DIR + "/images/greek/64.png", "\\Omega", null},
        {Config.DATA_DIR + "/images/greek/65.png", "\\varOmega", "amsmath"}
    };

    private const SymbolInfo[] symbols_arrows =
    {
        {Config.DATA_DIR + "/images/arrows/01.png", "\\leftarrow", null},
        {Config.DATA_DIR + "/images/arrows/02.png", "\\leftrightarrow", null},
        {Config.DATA_DIR + "/images/arrows/03.png", "\\rightarrow", null},
        {Config.DATA_DIR + "/images/arrows/04.png", "\\mapsto", null},
        {Config.DATA_DIR + "/images/arrows/05.png", "\\longleftarrow", null},
        {Config.DATA_DIR + "/images/arrows/06.png", "\\longleftrightarrow", null},
        {Config.DATA_DIR + "/images/arrows/07.png", "\\longrightarrow", null},
        {Config.DATA_DIR + "/images/arrows/08.png", "\\longmapsto", null},
        {Config.DATA_DIR + "/images/arrows/09.png", "\\downarrow", null},
        {Config.DATA_DIR + "/images/arrows/10.png", "\\updownarrow", null},
        {Config.DATA_DIR + "/images/arrows/11.png", "\\uparrow", null},
        {Config.DATA_DIR + "/images/arrows/12.png", "\\nwarrow", null},
        {Config.DATA_DIR + "/images/arrows/13.png", "\\searrow", null},
        {Config.DATA_DIR + "/images/arrows/14.png", "\\nearrow", null},
        {Config.DATA_DIR + "/images/arrows/15.png", "\\swarrow", null},
        {Config.DATA_DIR + "/images/arrows/16.png", "\\textdownarrow", "textcomp"},
        {Config.DATA_DIR + "/images/arrows/17.png", "\\textuparrow", "textcomp"},
        {Config.DATA_DIR + "/images/arrows/18.png", "\\textleftarrow", "textcomp"},
        {Config.DATA_DIR + "/images/arrows/19.png", "\\textrightarrow", "textcomp"},
        {Config.DATA_DIR + "/images/arrows/20.png", "\\nleftarrow", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/21.png", "\\nleftrightarrow", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/22.png", "\\nrightarrow", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/23.png", "\\hookleftarrow", null},
        {Config.DATA_DIR + "/images/arrows/24.png", "\\hookrightarrow", null},
        {Config.DATA_DIR + "/images/arrows/25.png", "\\twoheadleftarrow", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/26.png", "\\twoheadrightarrow", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/27.png", "\\leftarrowtail", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/28.png", "\\rightarrowtail", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/29.png", "\\Leftarrow", null},
        {Config.DATA_DIR + "/images/arrows/30.png", "\\Leftrightarrow", null},
        {Config.DATA_DIR + "/images/arrows/31.png", "\\Rightarrow", null},
        {Config.DATA_DIR + "/images/arrows/32.png", "\\Longleftarrow", null},
        {Config.DATA_DIR + "/images/arrows/33.png", "\\Longleftrightarrow", null},
        {Config.DATA_DIR + "/images/arrows/34.png", "\\Longrightarrow", null},
        {Config.DATA_DIR + "/images/arrows/35.png", "\\Updownarrow", null},
        {Config.DATA_DIR + "/images/arrows/36.png", "\\Uparrow", null},
        {Config.DATA_DIR + "/images/arrows/37.png", "\\Downarrow", null},
        {Config.DATA_DIR + "/images/arrows/38.png", "\\nLeftarrow", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/39.png", "\\nLeftrightarrow", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/40.png", "\\nRightarrow", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/41.png", "\\leftleftarrows", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/42.png", "\\leftrightarrows", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/43.png", "\\rightleftarrows", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/44.png", "\\rightrightarrows", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/45.png", "\\downdownarrows", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/46.png", "\\upuparrows", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/47.png", "\\circlearrowleft", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/48.png", "\\circlearrowright", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/49.png", "\\curvearrowleft", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/50.png", "\\curvearrowright", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/51.png", "\\Lsh", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/52.png", "\\Rsh", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/53.png", "\\looparrowleft", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/54.png", "\\looparrowright", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/55.png", "\\dashleftarrow", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/56.png", "\\dashrightarrow", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/57.png", "\\leftrightsquigarrow", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/58.png", "\\rightsquigarrow", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/59.png", "\\Lleftarrow", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/60.png", "\\leftharpoondown", null},
        {Config.DATA_DIR + "/images/arrows/61.png", "\\rightharpoondown", null},
        {Config.DATA_DIR + "/images/arrows/62.png", "\\leftharpoonup", null},
        {Config.DATA_DIR + "/images/arrows/63.png", "\\rightharpoonup", null},
        {Config.DATA_DIR + "/images/arrows/64.png", "\\rightleftharpoons", null},
        {Config.DATA_DIR + "/images/arrows/65.png", "\\leftrightharpoons", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/66.png", "\\downharpoonleft", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/67.png", "\\upharpoonleft", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/68.png", "\\downharpoonright", "amssymb"},
        {Config.DATA_DIR + "/images/arrows/69.png", "\\upharpoonright", "amssymb"}
    };

    private const SymbolInfo[] symbols_relations =
    {
        {Config.DATA_DIR + "/images/relations/001.png", "\\bowtie", null},
        {Config.DATA_DIR + "/images/relations/002.png", "\\Join", "amssymb"},
        {Config.DATA_DIR + "/images/relations/003.png", "\\propto", null},
        {Config.DATA_DIR + "/images/relations/004.png", "\\varpropto", "amssymb"},
        {Config.DATA_DIR + "/images/relations/005.png", "\\multimap", "amssymb"},
        {Config.DATA_DIR + "/images/relations/006.png", "\\pitchfork", "amssymb"},
        {Config.DATA_DIR + "/images/relations/007.png", "\\therefore", "amssymb"},
        {Config.DATA_DIR + "/images/relations/008.png", "\\because", "amssymb"},
        {Config.DATA_DIR + "/images/relations/009.png", "=", null},
        {Config.DATA_DIR + "/images/relations/010.png", "\\neq", null},
        {Config.DATA_DIR + "/images/relations/011.png", "\\equiv", null},
        {Config.DATA_DIR + "/images/relations/012.png", "\\approx", null},
        {Config.DATA_DIR + "/images/relations/013.png", "\\sim", null},
        {Config.DATA_DIR + "/images/relations/014.png", "\\simeq", null},
        {Config.DATA_DIR + "/images/relations/015.png", "\\backsimeq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/016.png", "\\approxeq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/017.png", "\\cong", null},
        {Config.DATA_DIR + "/images/relations/018.png", "\\ncong", "amssymb"},
        {Config.DATA_DIR + "/images/relations/019.png", "\\smile", null},
        {Config.DATA_DIR + "/images/relations/020.png", "\\frown", null},
        {Config.DATA_DIR + "/images/relations/021.png", "\\asymp", null},
        {Config.DATA_DIR + "/images/relations/022.png", "\\smallfrown", "amssymb"},
        {Config.DATA_DIR + "/images/relations/023.png", "\\smallsmile", "amssymb"},
        {Config.DATA_DIR + "/images/relations/024.png", "\\between", "amssymb"},
        {Config.DATA_DIR + "/images/relations/025.png", "\\prec", null},
        {Config.DATA_DIR + "/images/relations/026.png", "\\succ", null},
        {Config.DATA_DIR + "/images/relations/027.png", "\\nprec", "amssymb"},
        {Config.DATA_DIR + "/images/relations/028.png", "\\nsucc", "amssymb"},
        {Config.DATA_DIR + "/images/relations/029.png", "\\preceq", null},
        {Config.DATA_DIR + "/images/relations/030.png", "\\succeq", null},
        {Config.DATA_DIR + "/images/relations/031.png", "\\npreceq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/032.png", "\\nsucceq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/033.png", "\\preccurlyeq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/034.png", "\\succcurlyeq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/035.png", "\\curlyeqprec", "amssymb"},
        {Config.DATA_DIR + "/images/relations/036.png", "\\curlyeqsucc", "amssymb"},
        {Config.DATA_DIR + "/images/relations/037.png", "\\precsim", "amssymb"},
        {Config.DATA_DIR + "/images/relations/038.png", "\\succsim", "amssymb"},
        {Config.DATA_DIR + "/images/relations/039.png", "\\precnsim", "amssymb"},
        {Config.DATA_DIR + "/images/relations/040.png", "\\succnsim", "amssymb"},
        {Config.DATA_DIR + "/images/relations/041.png", "\\precapprox", "amssymb"},
        {Config.DATA_DIR + "/images/relations/042.png", "\\succapprox", "amssymb"},
        {Config.DATA_DIR + "/images/relations/043.png", "\\precnapprox", "amssymb"},
        {Config.DATA_DIR + "/images/relations/044.png", "\\succnapprox", "amssymb"},
        {Config.DATA_DIR + "/images/relations/045.png", "\\perp", null},
        {Config.DATA_DIR + "/images/relations/046.png", "\\vdash", null},
        {Config.DATA_DIR + "/images/relations/047.png", "\\dashv", null},
        {Config.DATA_DIR + "/images/relations/048.png", "\\nvdash", "amssymb"},
        {Config.DATA_DIR + "/images/relations/049.png", "\\Vdash", "amssymb"},
        {Config.DATA_DIR + "/images/relations/050.png", "\\Vvdash", "amssymb"},
        {Config.DATA_DIR + "/images/relations/051.png", "\\models", null},
        {Config.DATA_DIR + "/images/relations/052.png", "\\vDash", "amssymb"},
        {Config.DATA_DIR + "/images/relations/053.png", "\\nvDash", "amssymb"},
        {Config.DATA_DIR + "/images/relations/054.png", "\\nVDash", "amssymb"},
        {Config.DATA_DIR + "/images/relations/055.png", "\\mid", null},
        {Config.DATA_DIR + "/images/relations/056.png", "\\nmid", "amssymb"},
        {Config.DATA_DIR + "/images/relations/057.png", "\\parallel", null},
        {Config.DATA_DIR + "/images/relations/058.png", "\\nparallel", "amssymb"},
        {Config.DATA_DIR + "/images/relations/059.png", "\\shortmid", "amssymb"},
        {Config.DATA_DIR + "/images/relations/060.png", "\\nshortmid", "amssymb"},
        {Config.DATA_DIR + "/images/relations/061.png", "\\shortparallel", "amssymb"},
        {Config.DATA_DIR + "/images/relations/062.png", "\\nshortparallel", "amssymb"},
        {Config.DATA_DIR + "/images/relations/063.png", "<", null},
        {Config.DATA_DIR + "/images/relations/064.png", ">", null},
        {Config.DATA_DIR + "/images/relations/065.png", "\\nless", "amssymb"},
        {Config.DATA_DIR + "/images/relations/066.png", "\\ngtr", "amssymb"},
        {Config.DATA_DIR + "/images/relations/067.png", "\\lessdot", "amssymb"},
        {Config.DATA_DIR + "/images/relations/068.png", "\\gtrdot", "amssymb"},
        {Config.DATA_DIR + "/images/relations/069.png", "\\ll", null},
        {Config.DATA_DIR + "/images/relations/070.png", "\\gg", null},
        {Config.DATA_DIR + "/images/relations/071.png", "\\lll", "amssymb"},
        {Config.DATA_DIR + "/images/relations/072.png", "\\ggg", "amssymb"},
        {Config.DATA_DIR + "/images/relations/073.png", "\\leq", null},
        {Config.DATA_DIR + "/images/relations/074.png", "\\geq", null},
        {Config.DATA_DIR + "/images/relations/075.png", "\\lneq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/076.png", "\\gneq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/077.png", "\\nleq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/078.png", "\\ngeq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/079.png", "\\leqq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/080.png", "\\geqq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/081.png", "\\lneqq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/082.png", "\\gneqq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/083.png", "\\lvertneqq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/084.png", "\\gvertneqq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/085.png", "\\nleqq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/086.png", "\\ngeqq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/087.png", "\\leqslant", "amssymb"},
        {Config.DATA_DIR + "/images/relations/088.png", "\\geqslant", "amssymb"},
        {Config.DATA_DIR + "/images/relations/089.png", "\\nleqslant", "amssymb"},
        {Config.DATA_DIR + "/images/relations/090.png", "\\ngeqslant", "amssymb"},
        {Config.DATA_DIR + "/images/relations/091.png", "\\eqslantless", "amssymb"},
        {Config.DATA_DIR + "/images/relations/092.png", "\\eqslantgtr", "amssymb"},
        {Config.DATA_DIR + "/images/relations/093.png", "\\lessgtr", "amssymb"},
        {Config.DATA_DIR + "/images/relations/094.png", "\\gtrless", "amssymb"},
        {Config.DATA_DIR + "/images/relations/095.png", "\\lesseqgtr", "amssymb"},
        {Config.DATA_DIR + "/images/relations/096.png", "\\gtreqless", "amssymb"},
        {Config.DATA_DIR + "/images/relations/097.png", "\\lesseqqgtr", "amssymb"},
        {Config.DATA_DIR + "/images/relations/098.png", "\\gtreqqless", "amssymb"},
        {Config.DATA_DIR + "/images/relations/099.png", "\\lesssim", "amssymb"},
        {Config.DATA_DIR + "/images/relations/100.png", "\\gtrsim", "amssymb"},
        {Config.DATA_DIR + "/images/relations/101.png", "\\lnsim", "amssymb"},
        {Config.DATA_DIR + "/images/relations/102.png", "\\gnsim", "amssymb"},
        {Config.DATA_DIR + "/images/relations/103.png", "\\lessapprox", "amssymb"},
        {Config.DATA_DIR + "/images/relations/104.png", "\\gtrapprox", "amssymb"},
        {Config.DATA_DIR + "/images/relations/105.png", "\\lnapprox", "amssymb"},
        {Config.DATA_DIR + "/images/relations/106.png", "\\gnapprox", "amssymb"},
        {Config.DATA_DIR + "/images/relations/107.png", "\\vartriangleleft", "amssymb"},
        {Config.DATA_DIR + "/images/relations/108.png", "\\vartriangleright", "amssymb"},
        {Config.DATA_DIR + "/images/relations/109.png", "\\ntriangleleft", "amssymb"},
        {Config.DATA_DIR + "/images/relations/110.png", "\\ntriangleright", "amssymb"},
        {Config.DATA_DIR + "/images/relations/111.png", "\\trianglelefteq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/112.png", "\\trianglerighteq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/113.png", "\\ntrianglelefteq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/114.png", "\\ntrianglerighteq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/115.png", "\\blacktriangleleft", "amssymb"},
        {Config.DATA_DIR + "/images/relations/116.png", "\\blacktriangleright", "amssymb"},
        {Config.DATA_DIR + "/images/relations/117.png", "\\subset", null},
        {Config.DATA_DIR + "/images/relations/118.png", "\\supset", null},
        {Config.DATA_DIR + "/images/relations/119.png", "\\subseteq", null},
        {Config.DATA_DIR + "/images/relations/120.png", "\\supseteq", null},
        {Config.DATA_DIR + "/images/relations/121.png", "\\subsetneq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/122.png", "\\supsetneq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/123.png", "\\varsubsetneq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/124.png", "\\varsupsetneq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/125.png", "\\nsubseteq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/126.png", "\\nsupseteq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/127.png", "\\subseteqq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/128.png", "\\supseteqq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/129.png", "\\subsetneqq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/130.png", "\\supsetneqq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/131.png", "\\nsubseteqq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/132.png", "\\nsupseteqq", "amssymb"},
        {Config.DATA_DIR + "/images/relations/133.png", "\\backepsilon", "amssymb"},
        {Config.DATA_DIR + "/images/relations/134.png", "\\Subset", "amssymb"},
        {Config.DATA_DIR + "/images/relations/135.png", "\\Supset", "amssymb"},
        {Config.DATA_DIR + "/images/relations/136.png", "\\sqsubset", "amssymb"},
        {Config.DATA_DIR + "/images/relations/137.png", "\\sqsupset", "amssymb"},
        {Config.DATA_DIR + "/images/relations/138.png", "\\sqsubseteq", null},
        {Config.DATA_DIR + "/images/relations/139.png", "\\sqsupseteq", null}
    };

    private const SymbolInfo[] symbols_operators =
    {
        {Config.DATA_DIR + "/images/operators/001.png", "\\pm", null},
        {Config.DATA_DIR + "/images/operators/002.png", "\\mp", null},
        {Config.DATA_DIR + "/images/operators/003.png", "\\times", null},
        {Config.DATA_DIR + "/images/operators/004.png", "\\div", null},
        {Config.DATA_DIR + "/images/operators/005.png", "\\ast", null},
        {Config.DATA_DIR + "/images/operators/006.png", "\\star", null},
        {Config.DATA_DIR + "/images/operators/007.png", "\\circ", null},
        {Config.DATA_DIR + "/images/operators/008.png", "\\bullet", null},
        {Config.DATA_DIR + "/images/operators/009.png", "\\divideontimes", "amssymb"},
        {Config.DATA_DIR + "/images/operators/010.png", "\\ltimes", "amssymb"},
        {Config.DATA_DIR + "/images/operators/011.png", "\\rtimes", "amssymb"},
        {Config.DATA_DIR + "/images/operators/012.png", "\\cdot", null},
        {Config.DATA_DIR + "/images/operators/013.png", "\\dotplus", "amssymb"},
        {Config.DATA_DIR + "/images/operators/014.png", "\\leftthreetimes", "amssymb"},
        {Config.DATA_DIR + "/images/operators/015.png", "\\rightthreetimes", "amssymb"},
        {Config.DATA_DIR + "/images/operators/016.png", "\\amalg", null},
        {Config.DATA_DIR + "/images/operators/017.png", "\\otimes", null},
        {Config.DATA_DIR + "/images/operators/018.png", "\\oplus", null},
        {Config.DATA_DIR + "/images/operators/019.png", "\\ominus", null},
        {Config.DATA_DIR + "/images/operators/020.png", "\\oslash", null},
        {Config.DATA_DIR + "/images/operators/021.png", "\\odot", null},
        {Config.DATA_DIR + "/images/operators/022.png", "\\circledcirc", "amssymb"},
        {Config.DATA_DIR + "/images/operators/023.png", "\\circleddash", "amssymb"},
        {Config.DATA_DIR + "/images/operators/024.png", "\\circledast", "amssymb"},
        {Config.DATA_DIR + "/images/operators/025.png", "\\bigcirc", null},
        {Config.DATA_DIR + "/images/operators/026.png", "\\boxdot", "amssymb"},
        {Config.DATA_DIR + "/images/operators/027.png", "\\boxminus", "amssymb"},
        {Config.DATA_DIR + "/images/operators/028.png", "\\boxplus", "amssymb"},
        {Config.DATA_DIR + "/images/operators/029.png", "\\boxtimes", "amssymb"},
        {Config.DATA_DIR + "/images/operators/030.png", "\\diamond", null},
        {Config.DATA_DIR + "/images/operators/031.png", "\\bigtriangleup", null},
        {Config.DATA_DIR + "/images/operators/032.png", "\\bigtriangledown", null},
        {Config.DATA_DIR + "/images/operators/033.png", "\\triangleleft", null},
        {Config.DATA_DIR + "/images/operators/034.png", "\\triangleright", null},
        {Config.DATA_DIR + "/images/operators/035.png", "\\lhd", "amssymb"},
        {Config.DATA_DIR + "/images/operators/036.png", "\\rhd", "amssymb"},
        {Config.DATA_DIR + "/images/operators/037.png", "\\unlhd", "amssymb"},
        {Config.DATA_DIR + "/images/operators/038.png", "\\unrhd", "amssymb"},
        {Config.DATA_DIR + "/images/operators/039.png", "\\cup", null},
        {Config.DATA_DIR + "/images/operators/040.png", "\\cap", null},
        {Config.DATA_DIR + "/images/operators/041.png", "\\uplus", null},
        {Config.DATA_DIR + "/images/operators/042.png", "\\Cup", "amssymb"},
        {Config.DATA_DIR + "/images/operators/043.png", "\\Cap", "amssymb"},
        {Config.DATA_DIR + "/images/operators/044.png", "\\wr", null},
        {Config.DATA_DIR + "/images/operators/045.png", "\\setminus", null},
        {Config.DATA_DIR + "/images/operators/046.png", "\\smallsetminus", "amssymb"},
        {Config.DATA_DIR + "/images/operators/047.png", "\\sqcap", null},
        {Config.DATA_DIR + "/images/operators/048.png", "\\sqcup", null},
        {Config.DATA_DIR + "/images/operators/049.png", "\\wedge", null},
        {Config.DATA_DIR + "/images/operators/050.png", "\\vee", null},
        {Config.DATA_DIR + "/images/operators/051.png", "\\barwedge", "amssymb"},
        {Config.DATA_DIR + "/images/operators/052.png", "\\veebar", "amssymb"},
        {Config.DATA_DIR + "/images/operators/053.png", "\\doublebarwedge", "amssymb"},
        {Config.DATA_DIR + "/images/operators/054.png", "\\curlywedge", "amssymb"},
        {Config.DATA_DIR + "/images/operators/055.png", "\\curlyvee", "amssymb"},
        {Config.DATA_DIR + "/images/operators/056.png", "\\dagger", "amssymb"},
        {Config.DATA_DIR + "/images/operators/057.png", "\\ddagger", "amssymb"},
        {Config.DATA_DIR + "/images/operators/058.png", "\\intercal", "amssymb"},
        {Config.DATA_DIR + "/images/operators/059.png", "\\bigcap", null},
        {Config.DATA_DIR + "/images/operators/060.png", "\\bigcup", null},
        {Config.DATA_DIR + "/images/operators/061.png", "\\biguplus", null},
        {Config.DATA_DIR + "/images/operators/062.png", "\\bigsqcup", null},
        {Config.DATA_DIR + "/images/operators/063.png", "\\prod", null},
        {Config.DATA_DIR + "/images/operators/064.png", "\\coprod", null},
        {Config.DATA_DIR + "/images/operators/065.png", "\\bigwedge", null},
        {Config.DATA_DIR + "/images/operators/066.png", "\\bigvee", null},
        {Config.DATA_DIR + "/images/operators/067.png", "\\bigodot", null},
        {Config.DATA_DIR + "/images/operators/068.png", "\\bigoplus", null},
        {Config.DATA_DIR + "/images/operators/069.png", "\\bigotimes", null},
        {Config.DATA_DIR + "/images/operators/070.png", "\\sum", null},
        {Config.DATA_DIR + "/images/operators/071.png", "\\int", null},
        {Config.DATA_DIR + "/images/operators/072.png", "\\oint", null},
        {Config.DATA_DIR + "/images/operators/073.png", "\\iint", "amsmath"},
        {Config.DATA_DIR + "/images/operators/074.png", "\\iiint", "amsmath"},
        {Config.DATA_DIR + "/images/operators/075.png", "\\iiiint", "amsmath"},
        {Config.DATA_DIR + "/images/operators/076.png", "\\idotsint", "amsmath"},
        {Config.DATA_DIR + "/images/operators/077.png", "\\arccos", null},
        {Config.DATA_DIR + "/images/operators/078.png", "\\arcsin", null},
        {Config.DATA_DIR + "/images/operators/079.png", "\\arctan", null},
        {Config.DATA_DIR + "/images/operators/080.png", "\\arg", null},
        {Config.DATA_DIR + "/images/operators/081.png", "\\cos", null},
        {Config.DATA_DIR + "/images/operators/082.png", "\\cosh", null},
        {Config.DATA_DIR + "/images/operators/083.png", "\\cot", null},
        {Config.DATA_DIR + "/images/operators/084.png", "\\coth", null},
        {Config.DATA_DIR + "/images/operators/085.png", "\\csc", null},
        {Config.DATA_DIR + "/images/operators/086.png", "\\deg", null},
        {Config.DATA_DIR + "/images/operators/087.png", "\\det", null},
        {Config.DATA_DIR + "/images/operators/088.png", "\\dim", null},
        {Config.DATA_DIR + "/images/operators/089.png", "\\exp", null},
        {Config.DATA_DIR + "/images/operators/090.png", "\\gcd", null},
        {Config.DATA_DIR + "/images/operators/091.png", "\\hom", null},
        {Config.DATA_DIR + "/images/operators/092.png", "\\inf", null},
        {Config.DATA_DIR + "/images/operators/093.png", "\\ker", null},
        {Config.DATA_DIR + "/images/operators/094.png", "\\lg", null},
        {Config.DATA_DIR + "/images/operators/095.png", "\\lim", null},
        {Config.DATA_DIR + "/images/operators/096.png", "\\liminf", null},
        {Config.DATA_DIR + "/images/operators/097.png", "\\limsup", null},
        {Config.DATA_DIR + "/images/operators/098.png", "\\ln", null},
        {Config.DATA_DIR + "/images/operators/099.png", "\\log", null},
        {Config.DATA_DIR + "/images/operators/100.png", "\\max", null},
        {Config.DATA_DIR + "/images/operators/101.png", "\\min", null},
        {Config.DATA_DIR + "/images/operators/102.png", "\\Pr", null},
        {Config.DATA_DIR + "/images/operators/103.png", "\\projlim", "amsmath"},
        {Config.DATA_DIR + "/images/operators/104.png", "\\sec", null},
        {Config.DATA_DIR + "/images/operators/105.png", "\\sin", null},
        {Config.DATA_DIR + "/images/operators/106.png", "\\sinh", null},
        {Config.DATA_DIR + "/images/operators/107.png", "\\sup", null},
        {Config.DATA_DIR + "/images/operators/108.png", "\\tan", null},
        {Config.DATA_DIR + "/images/operators/109.png", "\\tanh", null},
        {Config.DATA_DIR + "/images/operators/110.png", "\\varlimsup", "amsmath"},
        {Config.DATA_DIR + "/images/operators/111.png", "\\varliminf", "amsmath"},
        {Config.DATA_DIR + "/images/operators/112.png", "\\varinjlim", "amsmath"},
        {Config.DATA_DIR + "/images/operators/113.png", "\\varprojlim", "amsmath"}
    };

    private const SymbolInfo[] symbols_delimiters =
    {
        {Config.DATA_DIR + "/images/delimiters/01.png", "\\downarrow", null},
        {Config.DATA_DIR + "/images/delimiters/02.png", "\\Downarrow", null},
        {Config.DATA_DIR + "/images/delimiters/03.png", "[", null},
        {Config.DATA_DIR + "/images/delimiters/04.png", "]", null},
        {Config.DATA_DIR + "/images/delimiters/05.png", "\\langle", null},
        {Config.DATA_DIR + "/images/delimiters/06.png", "\\rangle", null},
        {Config.DATA_DIR + "/images/delimiters/07.png", "|", null},
        {Config.DATA_DIR + "/images/delimiters/08.png", "\\|", null},
        {Config.DATA_DIR + "/images/delimiters/09.png", "\\lceil", null},
        {Config.DATA_DIR + "/images/delimiters/10.png", "\\rceil", null},
        {Config.DATA_DIR + "/images/delimiters/11.png", "\\uparrow", null},
        {Config.DATA_DIR + "/images/delimiters/12.png", "\\Uparrow", null},
        {Config.DATA_DIR + "/images/delimiters/13.png", "\\lfloor", null},
        {Config.DATA_DIR + "/images/delimiters/14.png", "\\rfloor", null},
        {Config.DATA_DIR + "/images/delimiters/15.png", "\\updownarrow", null},
        {Config.DATA_DIR + "/images/delimiters/16.png", "\\Updownarrow", null},
        {Config.DATA_DIR + "/images/delimiters/17.png", "(", null},
        {Config.DATA_DIR + "/images/delimiters/18.png", ")", null},
        {Config.DATA_DIR + "/images/delimiters/19.png", "\\{", null},
        {Config.DATA_DIR + "/images/delimiters/20.png", "\\}", null},
        {Config.DATA_DIR + "/images/delimiters/21.png", "/", null},
        {Config.DATA_DIR + "/images/delimiters/22.png", "\\backslash", null},
        {Config.DATA_DIR + "/images/delimiters/23.png", "\\lmoustache", null},
        {Config.DATA_DIR + "/images/delimiters/24.png", "\\rmoustache", null},
        {Config.DATA_DIR + "/images/delimiters/25.png", "\\lgroup", null},
        {Config.DATA_DIR + "/images/delimiters/26.png", "\\rgroup", null},
        {Config.DATA_DIR + "/images/delimiters/27.png", "\\arrowvert", null},
        {Config.DATA_DIR + "/images/delimiters/28.png", "\\Arrowvert", null},
        {Config.DATA_DIR + "/images/delimiters/29.png", "\\bracevert", null},
        {Config.DATA_DIR + "/images/delimiters/30.png", "\\lvert", "amsmath"},
        {Config.DATA_DIR + "/images/delimiters/31.png", "\\rvert", "amsmath"},
        {Config.DATA_DIR + "/images/delimiters/32.png", "\\lVert", "amsmath"},
        {Config.DATA_DIR + "/images/delimiters/33.png", "\\rVert", "amsmath"},
        {Config.DATA_DIR + "/images/delimiters/34.png", "\\ulcorner", "amssymb"},
        {Config.DATA_DIR + "/images/delimiters/35.png", "\\urcorner", "amssymb"},
        {Config.DATA_DIR + "/images/delimiters/36.png", "\\llcorner", "amssymb"},
        {Config.DATA_DIR + "/images/delimiters/37.png", "\\lrcorner", "amssymb"}
    };

    private const SymbolInfo[] symbols_misc_math =
    {
        {Config.DATA_DIR + "/images/misc-math/01.png", "\\cdotp", null},
        {Config.DATA_DIR + "/images/misc-math/02.png", "\\colon", null},
        {Config.DATA_DIR + "/images/misc-math/03.png", "\\ldotp", null},
        {Config.DATA_DIR + "/images/misc-math/04.png", "\\vdots", null},
        {Config.DATA_DIR + "/images/misc-math/05.png", "\\cdots", null},
        {Config.DATA_DIR + "/images/misc-math/06.png", "\\ddots", null},
        {Config.DATA_DIR + "/images/misc-math/07.png", "\\ldots", null},
        {Config.DATA_DIR + "/images/misc-math/08.png", "\\neg", null},
        {Config.DATA_DIR + "/images/misc-math/09.png", "\\infty", null},
        {Config.DATA_DIR + "/images/misc-math/10.png", "\\prime", null},
        {Config.DATA_DIR + "/images/misc-math/11.png", "\\backprime", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/12.png", "\\backslash", null},
        {Config.DATA_DIR + "/images/misc-math/13.png", "\\diagdown", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/14.png", "\\diagup", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/15.png", "\\surd", null},
        {Config.DATA_DIR + "/images/misc-math/16.png", "\\emptyset", null},
        {Config.DATA_DIR + "/images/misc-math/17.png", "\\varnothing", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/18.png", "\\sharp", null},
        {Config.DATA_DIR + "/images/misc-math/19.png", "\\flat", null},
        {Config.DATA_DIR + "/images/misc-math/20.png", "\\natural", null},
        {Config.DATA_DIR + "/images/misc-math/21.png", "\\angle", null},
        {Config.DATA_DIR + "/images/misc-math/22.png", "\\sphericalangle", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/23.png", "\\measuredangle", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/24.png", "\\Box", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/25.png", "\\square", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/26.png", "\\triangle", null},
        {Config.DATA_DIR + "/images/misc-math/27.png", "\\vartriangle", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/28.png", "\\triangledown", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/29.png", "\\Diamond", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/30.png", "\\diamondsuit", null},
        {Config.DATA_DIR + "/images/misc-math/31.png", "\\lozenge", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/32.png", "\\heartsuit", null},
        {Config.DATA_DIR + "/images/misc-math/33.png", "\\blacksquare", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/34.png", "\\blacktriangle", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/35.png", "\\blacktriangledown", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/36.png", "\\blacklozenge", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/37.png", "\\bigstar", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/38.png", "\\spadesuit", null},
        {Config.DATA_DIR + "/images/misc-math/39.png", "\\clubsuit", null},
        {Config.DATA_DIR + "/images/misc-math/40.png", "\\forall", null},
        {Config.DATA_DIR + "/images/misc-math/41.png", "\\exists", null},
        {Config.DATA_DIR + "/images/misc-math/42.png", "\\nexists", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/43.png", "\\Finv", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/44.png", "\\Game", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/45.png", "\\ni", null},
        {Config.DATA_DIR + "/images/misc-math/46.png", "\\in", null},
        {Config.DATA_DIR + "/images/misc-math/47.png", "\\notin", null},
        {Config.DATA_DIR + "/images/misc-math/48.png", "\\complement", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/set-N.png", "\\mathbb{N}", "amsfonts"},
        {Config.DATA_DIR + "/images/misc-math/set-Z.png", "\\mathbb{Z}", "amsfonts"},
        {Config.DATA_DIR + "/images/misc-math/set-Q.png", "\\mathbb{Q}", "amsfonts"},
        {Config.DATA_DIR + "/images/misc-math/set-I.png", "\\mathbb{I}", "amsfonts"},
        {Config.DATA_DIR + "/images/misc-math/set-R.png", "\\mathbb{R}", "amsfonts"},
        {Config.DATA_DIR + "/images/misc-math/set-C.png", "\\mathbb{C}", "amsfonts"},
        {Config.DATA_DIR + "/images/misc-math/49.png", "\\Im", null},
        {Config.DATA_DIR + "/images/misc-math/50.png", "\\Re", null},
        {Config.DATA_DIR + "/images/misc-math/51.png", "\\aleph", null},
        {Config.DATA_DIR + "/images/misc-math/52.png", "\\wp", null},
        {Config.DATA_DIR + "/images/misc-math/53.png", "\\hslash", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/54.png", "\\hbar", null},
        {Config.DATA_DIR + "/images/misc-math/55.png", "\\imath", null},
        {Config.DATA_DIR + "/images/misc-math/56.png", "\\jmath", null},
        {Config.DATA_DIR + "/images/misc-math/57.png", "\\Bbbk", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/58.png", "\\ell", null},
        {Config.DATA_DIR + "/images/misc-math/59.png", "\\circledR", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/60.png", "\\circledS", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/61.png", "\\bot", null},
        {Config.DATA_DIR + "/images/misc-math/62.png", "\\top", null},
        {Config.DATA_DIR + "/images/misc-math/63.png", "\\partial", null},
        {Config.DATA_DIR + "/images/misc-math/64.png", "\\nabla", null},
        {Config.DATA_DIR + "/images/misc-math/65.png", "\\eth", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/66.png", "\\mho", "amssymb"},
        {Config.DATA_DIR + "/images/misc-math/67.png", "\\acute{}", null},
        {Config.DATA_DIR + "/images/misc-math/68.png", "\\grave{}", null},
        {Config.DATA_DIR + "/images/misc-math/69.png", "\\check{}", null},
        {Config.DATA_DIR + "/images/misc-math/70.png", "\\hat{}", null},
        {Config.DATA_DIR + "/images/misc-math/71.png", "\\tilde{}", null},
        {Config.DATA_DIR + "/images/misc-math/72.png", "\\bar{}", null},
        {Config.DATA_DIR + "/images/misc-math/73.png", "\\vec{}", null},
        {Config.DATA_DIR + "/images/misc-math/74.png", "\\breve{}", null},
        {Config.DATA_DIR + "/images/misc-math/75.png", "\\dot{}", null},
        {Config.DATA_DIR + "/images/misc-math/76.png", "\\ddot{}", null},
        {Config.DATA_DIR + "/images/misc-math/77.png", "\\dddot{}", "amsmath"},
        {Config.DATA_DIR + "/images/misc-math/78.png", "\\ddddot{}", "amsmath"},
        {Config.DATA_DIR + "/images/misc-math/79.png", "\\mathring{}", null},
        {Config.DATA_DIR + "/images/misc-math/80.png", "\\widetilde{}", null},
        {Config.DATA_DIR + "/images/misc-math/81.png", "\\widehat{}", null},
        {Config.DATA_DIR + "/images/misc-math/82.png", "\\overleftarrow{}", null},
        {Config.DATA_DIR + "/images/misc-math/83.png", "\\overrightarrow{}", null},
        {Config.DATA_DIR + "/images/misc-math/84.png", "\\overline{}", null},
        {Config.DATA_DIR + "/images/misc-math/85.png", "\\underline{}", null},
        {Config.DATA_DIR + "/images/misc-math/86.png", "\\overbrace{}", null},
        {Config.DATA_DIR + "/images/misc-math/87.png", "\\underbrace{}", null},
        {Config.DATA_DIR + "/images/misc-math/88.png", "\\overleftrightarrow{}", "amsmath"},
        {Config.DATA_DIR + "/images/misc-math/89.png", "\\underleftrightarrow{}", "amsmath"},
        {Config.DATA_DIR + "/images/misc-math/90.png", "\\underleftarrow{}", "amsmath"},
        {Config.DATA_DIR + "/images/misc-math/91.png", "\\underrightarrow{}", "amsmath"},
        {Config.DATA_DIR + "/images/misc-math/92.png", "\\xleftarrow{}", "amsmath"},
        {Config.DATA_DIR + "/images/misc-math/93.png", "\\xrightarrow{}", "amsmath"},
        {Config.DATA_DIR + "/images/misc-math/94.png", "\\stackrel{}{}", null},
        {Config.DATA_DIR + "/images/misc-math/95.png", "\\sqrt{}", null},
        {Config.DATA_DIR + "/images/misc-math/96.png", "f'", null},
        {Config.DATA_DIR + "/images/misc-math/97.png", "f''", null}
    };

    private const SymbolInfo[] symbols_misc_text =
    {
        {Config.DATA_DIR + "/images/misc-text/001.png", "\\dots", null},
        {Config.DATA_DIR + "/images/misc-text/002.png", "\\texttildelow", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/003.png", "\\textasciicircum", null},
        {Config.DATA_DIR + "/images/misc-text/004.png", "\\textasciimacron", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/005.png", "\\textasciiacute", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/006.png", "\\textasciidieresis", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/007.png", "\\textasciitilde", null},
        {Config.DATA_DIR + "/images/misc-text/008.png", "\\textasciigrave", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/009.png", "\\textasciibreve", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/010.png", "\\textasciicaron", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/011.png", "\\textacutedbl", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/012.png", "\\textgravedbl", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/013.png", "\\textquotedblleft", null},
        {Config.DATA_DIR + "/images/misc-text/014.png", "\\textquotedblright", null},
        {Config.DATA_DIR + "/images/misc-text/015.png", "\\textquoteleft", null},
        {Config.DATA_DIR + "/images/misc-text/016.png", "\\textquoteright", null},
        {Config.DATA_DIR + "/images/misc-text/017.png", "\\textquotestraightbase", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/018.png", "\\textquotestraightdblbase", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/019.png", "\\textquotesingle", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/020.png", "\\textdblhyphen", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/021.png", "\\textdblhyphenchar", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/022.png", "\\textasteriskcentered", null},
        {Config.DATA_DIR + "/images/misc-text/023.png", "\\textperiodcentered", null},
        {Config.DATA_DIR + "/images/misc-text/024.png", "\\textquestiondown", null},
        {Config.DATA_DIR + "/images/misc-text/025.png", "\\textinterrobang", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/026.png", "\\textinterrobangdown", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/027.png", "\\textexclamdown", null},
        {Config.DATA_DIR + "/images/misc-text/028.png", "\\texttwelveudash", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/029.png", "\\textemdash", null},
        {Config.DATA_DIR + "/images/misc-text/030.png", "\\textendash", null},
        {Config.DATA_DIR + "/images/misc-text/031.png", "\\textthreequartersemdash", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/032.png", "\\textvisiblespace", null},
        {Config.DATA_DIR + "/images/misc-text/033.png", "\\_", null},
        {Config.DATA_DIR + "/images/misc-text/034.png", "\\textcurrency", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/035.png", "\\textbaht", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/036.png", "\\textguarani", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/037.png", "\\textwon", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/038.png", "\\textcent", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/039.png", "\\textcentoldstyle", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/040.png", "\\textdollar", null},
        {Config.DATA_DIR + "/images/misc-text/041.png", "\\textdollaroldstyle", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/042.png", "\\textlira", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/043.png", "\\textyen", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/044.png", "\\textdong", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/045.png", "\\textnaira", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/046.png", "\\textcolonmonetary", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/047.png", "\\textpeso", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/048.png", "\\pounds", null},
        {Config.DATA_DIR + "/images/misc-text/049.png", "\\textflorin", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/050.png", "\\texteuro", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/051.png", "\\geneuro", "eurosym"},
        {Config.DATA_DIR + "/images/misc-text/052.png", "\\geneuronarrow", "eurosym"},
        {Config.DATA_DIR + "/images/misc-text/053.png", "\\geneurowide", "eurosym"},
        {Config.DATA_DIR + "/images/misc-text/054.png", "\\officialeuro", "eurosym"},
        {Config.DATA_DIR + "/images/misc-text/055.png", "\\textcircled{a}", null},
        {Config.DATA_DIR + "/images/misc-text/056.png", "\\textcopyright", null},
        {Config.DATA_DIR + "/images/misc-text/057.png", "\\textcopyleft", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/058.png", "\\textregistered", null},
        {Config.DATA_DIR + "/images/misc-text/059.png", "\\texttrademark", null},
        {Config.DATA_DIR + "/images/misc-text/060.png", "\\textservicemark", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/061.png", "\\oldstylenums{0}", null},
        {Config.DATA_DIR + "/images/misc-text/062.png", "\\oldstylenums{1}", null},
        {Config.DATA_DIR + "/images/misc-text/063.png", "\\oldstylenums{2}", null},
        {Config.DATA_DIR + "/images/misc-text/064.png", "\\oldstylenums{3}", null},
        {Config.DATA_DIR + "/images/misc-text/065.png", "\\oldstylenums{4}", null},
        {Config.DATA_DIR + "/images/misc-text/066.png", "\\oldstylenums{5}", null},
        {Config.DATA_DIR + "/images/misc-text/067.png", "\\oldstylenums{6}", null},
        {Config.DATA_DIR + "/images/misc-text/068.png", "\\oldstylenums{7}", null},
        {Config.DATA_DIR + "/images/misc-text/069.png", "\\oldstylenums{8}", null},
        {Config.DATA_DIR + "/images/misc-text/070.png", "\\oldstylenums{9}", null},
        {Config.DATA_DIR + "/images/misc-text/071.png", "\\textonehalf", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/072.png", "\\textonequarter", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/073.png", "\\textthreequarters", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/074.png", "\\textonesuperior", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/075.png", "\\texttwosuperior", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/076.png", "\\textthreesuperior", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/077.png", "\\textnumero", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/078.png", "\\textpertenthousand", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/079.png", "\\textperthousand", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/080.png", "\\textdiscount", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/081.png", "\\textblank", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/082.png", "\\textrecipe", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/083.png", "\\textestimated", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/084.png", "\\textreferencemark", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/085.png", "\\textmusicalnote", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/086.png", "\\dag", null},
        {Config.DATA_DIR + "/images/misc-text/087.png", "\\ddag", null},
        {Config.DATA_DIR + "/images/misc-text/088.png", "\\S", null},
        {Config.DATA_DIR + "/images/misc-text/089.png", "\\$", null},
        {Config.DATA_DIR + "/images/misc-text/090.png", "\\textpilcrow", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/091.png", "\\Cutleft", "marvosym"},
        {Config.DATA_DIR + "/images/misc-text/092.png", "\\Cutright", "marvosym"},
        {Config.DATA_DIR + "/images/misc-text/093.png", "\\Leftscissors", "marvosym"},
        {Config.DATA_DIR + "/images/misc-text/094.png", "\\Cutline", "marvosym"},
        {Config.DATA_DIR + "/images/misc-text/095.png", "\\Kutline", "marvosym"},
        {Config.DATA_DIR + "/images/misc-text/096.png", "\\Rightscissors", "marvosym"},
        {Config.DATA_DIR + "/images/misc-text/097.png", "\\CheckedBox", "wasysym"},
        {Config.DATA_DIR + "/images/misc-text/098.png", "\\Square", "wasysym"},
        {Config.DATA_DIR + "/images/misc-text/099.png", "\\XBox", "wasysym"},
        {Config.DATA_DIR + "/images/misc-text/100.png", "\\textbigcircle", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/101.png", "\\textopenbullet", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/102.png", "\\textbullet", null},
        {Config.DATA_DIR + "/images/misc-text/103.png", "\\checkmark", "amssymb"},
        {Config.DATA_DIR + "/images/misc-text/104.png", "\\maltese", "amssymb"},
        {Config.DATA_DIR + "/images/misc-text/105.png", "\\textordmasculine", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/106.png", "\\textordfeminine", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/107.png", "\\textborn", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/108.png", "\\textdivorced", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/109.png", "\\textdied", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/110.png", "\\textmarried", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/111.png", "\\textleaf", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/112.png", "\\textcelsius", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/113.png", "\\textdegree", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/114.png", "\\textmho", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/115.png", "\\textohm", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/116.png", "\\textbackslash", null},
        {Config.DATA_DIR + "/images/misc-text/117.png", "\\textbar", null},
        {Config.DATA_DIR + "/images/misc-text/118.png", "\\textbrokenbar", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/119.png", "\\textbardbl", null},
        {Config.DATA_DIR + "/images/misc-text/120.png", "\\textfractionsolidus", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/121.png", "\\textlangle", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/122.png", "\\textlnot", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/123.png", "\\textminus", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/124.png", "\\textrangle", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/125.png", "\\textlbrackdbl", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/126.png", "\\textrbrackdbl", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/127.png", "\\textmu", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/128.png", "\\textpm", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/129.png", "\\textlquill", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/130.png", "\\textrquill", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/131.png", "\\textless", null},
        {Config.DATA_DIR + "/images/misc-text/132.png", "\\textgreater", null},
        {Config.DATA_DIR + "/images/misc-text/133.png", "\\textsurd", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/134.png", "\\texttimes", "textcomp"},
        {Config.DATA_DIR + "/images/misc-text/135.png", "\\textdiv", "textcomp"}
    };

    private static bool stores_initialized = false;
    private static ListStore categories_store;
    private static ListStore[] symbols_stores = new ListStore[7];

    public Symbols (MainWindow main_window)
    {
        if (! stores_initialized)
        {
            /* categories store */
            categories_store = new ListStore (CategoryColumn.N_COLUMNS,
                typeof (Gdk.Pixbuf), typeof (string), typeof (int));

            int i = 0;
            foreach (CategoryInfo info in categories)
            {
                try
                {
                    var pixbuf = new Gdk.Pixbuf.from_file (info.icon);
                    TreeIter iter;
                    categories_store.append (out iter);
                    categories_store.set (iter,
                        CategoryColumn.ICON, pixbuf,
                        CategoryColumn.NAME, _(info.name),
                        CategoryColumn.NUM, i,
                        -1);
                }
                catch (Error e)
                {
                    stderr.printf ("Warning: impossible to load the symbol: %s\n",
                        e.message);
                    continue;
                }

                i++;
            }

            /* symbols stores */
            symbols_stores[0] = get_symbol_store (symbols_greek);
            symbols_stores[1] = get_symbol_store (symbols_arrows);
            symbols_stores[2] = get_symbol_store (symbols_relations);
            symbols_stores[3] = get_symbol_store (symbols_operators);
            symbols_stores[4] = get_symbol_store (symbols_delimiters);
            symbols_stores[5] = get_symbol_store (symbols_misc_math);
            symbols_stores[6] = get_symbol_store (symbols_misc_text);

            stores_initialized = true;
        }

        create_icon_views (main_window);
    }

    private void create_icon_views (MainWindow main_window)
    {
        /* show the categories */
        IconView categories_view = new IconView.with_model (categories_store);
        categories_view.set_pixbuf_column (CategoryColumn.ICON);
        categories_view.set_text_column (CategoryColumn.NAME);
        categories_view.set_selection_mode (SelectionMode.SINGLE);
        categories_view.set_orientation (Orientation.HORIZONTAL);
        categories_view.spacing = 5;
        categories_view.row_spacing = 0;
        categories_view.column_spacing = 0;

        pack_start (categories_view, false, false, 0);

        /* show the symbols */
        IconView symbol_view = new IconView.with_model (symbols_stores[0]);
        symbol_view.set_pixbuf_column (SymbolColumn.PIXBUF);
        symbol_view.set_tooltip_column (SymbolColumn.TOOLTIP);
        symbol_view.set_selection_mode (SelectionMode.SINGLE);
        symbol_view.spacing = 0;
        symbol_view.row_spacing = 0;
        symbol_view.column_spacing = 0;

        var sw = Utils.add_scrollbar (symbol_view);
        pack_start (sw);

        /* signals */
        categories_view.selection_changed.connect (() =>
        {
            var selected_items = categories_view.get_selected_items ();
            TreePath path = selected_items.nth_data (0);
            TreeModel model = (TreeModel) categories_store;
            TreeIter iter = {};

            if (path != null && model.get_iter (out iter, path))
            {
                int num;
                model.get (iter, CategoryColumn.NUM, out num, -1);

                // change the model
                symbol_view.set_model (symbols_stores[num]);
            }
        });

        symbol_view.selection_changed.connect (() =>
        {
            if (main_window.active_tab == null)
            {
                symbol_view.unselect_all ();
                return;
            }

            var selected_items = symbol_view.get_selected_items ();

            // unselect the symbol, so the user can insert several times the same symbol
            symbol_view.unselect_all ();

            var path = selected_items.nth_data (0);
            var model = symbol_view.get_model ();
            TreeIter iter = {};

            if (path != null && model.get_iter (out iter, path))
            {
                string latex_command;
                model.get (iter, SymbolColumn.COMMAND, out latex_command, -1);

                // insert the symbol in the current document
                main_window.active_document.begin_user_action ();
                main_window.active_document.insert_at_cursor (latex_command, -1);
                main_window.active_document.insert_at_cursor (" ", -1);
                main_window.active_document.end_user_action ();
                main_window.active_view.grab_focus ();
            }
        });
    }

    private ListStore get_symbol_store (SymbolInfo[] symbols)
    {
        ListStore symbol_store = new ListStore (SymbolColumn.N_COLUMNS,
            typeof (Gdk.Pixbuf), typeof (string), typeof (string));

        foreach (SymbolInfo symbol in symbols)
        {
            try
            {
                var pixbuf = new Gdk.Pixbuf.from_file (symbol.filename);

                // some characters ('<' for example) generate errors for the tooltip,
		        // so we must escape it
		        string tooltip = Markup.escape_text (symbol.latex_command);

		        if (symbol.package_required != null)
		            tooltip += " (package %s)".printf (symbol.package_required);

                TreeIter iter;
                symbol_store.append (out iter);
                symbol_store.set (iter,
                    SymbolColumn.PIXBUF, pixbuf,
                    SymbolColumn.COMMAND, symbol.latex_command,
                    SymbolColumn.TOOLTIP, tooltip,
                    -1);
            }
            catch (Error e)
            {
                stderr.printf ("Warning: impossible to load the symbol: %s\n", e.message);
                continue;
            }
        }

        return symbol_store;
    }
}
