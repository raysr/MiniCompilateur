%{ 
#include <stdio.h> 
#include<string.h>
#include "ts.h"
#include "quad.h"
extern nb_ligne;
extern nb_colonne;
int t=0; // Compteur des états temporaires
int qc=0;
char tmp[20],tmp2[20],tmp3[20],type[20],tmp4[20];
int x=0;
int jump;

%}

%union {
int entier;
float reel;
char* chaine;}

%token  mc_ALGORITHME <chaine>mc_entier <chaine>mc_reel <chaine>mc_chaine mc_VAR mc_DEBUT mc_FIN mc_Pour mc_jusque mc_Faire mc_Fait mc_SI op_AFF <chaine>op_comp <chaine>op_arith bar parenthese_gauche parenthese_droite <chaine>identificateur <entier>const_entier <reel>const_reel <chaine>const_chaine dp pvg crochet_gauche crochet_droit  


%%

structure_generale:dec_algo mc_VAR partieDeclaration mc_DEBUT partieInstruction mc_FIN {printf("----------programme syntaxiquement juste------\n ecrire quelque chose puis appuyer sur entre pour afficher la table des symboles et des quadruplets");}
;



//-------------------------declaration de l'algorithme-----------
dec_algo: mc_ALGORITHME identificateur 
;

//-------------Partie Declaration--------------
partieDeclaration: dec_var2 partieDeclaration 
						  | dec_var2	
				  |dec_tableau partieDeclaration
					         | dec_tableau
				  |dec_var partieDeclaration
						 | dec_var
;

//----------------les declarations------------
dec_tableau: identificateur crochet_gauche const_entier crochet_droit dp mc_entier pvg {inserer($1,"entier",$3);}
	         |identificateur crochet_gauche const_entier crochet_droit dp mc_reel pvg   {inserer($1,"reel",$3);}
			 |identificateur crochet_gauche const_entier crochet_droit dp mc_chaine pvg  {inserer($1,"chaine",$3);}
;

dec_var2: mc_entier ListeIDF pvg {inserer($3,"entier",1);}
		 | mc_reel ListeIDF pvg   {inserer($3,"reel",1);}
		 | mc_chaine ListeIDF pvg  {inserer($3,"chaine",1);}
;

dec_var: identificateur dp mc_entier pvg {inserer($1,"entier",1);}
	     |identificateur dp mc_reel pvg  {inserer($1,"reel",1);}
         | identificateur dp mc_chaine pvg {inserer($1,"chaine",1);}
;


ListeIDF: identificateur bar ListeIDF {if(recherche($1)!=-1) printf("-----------ERREUR:semantique - la variable: %s deja declare ligne %d  \n ",$1,nb_ligne,"------------");}
			           | identificateur  {if(recherche($1)!=-1) printf("-----------ERREUR:semantique - la variable: %s deja déclare ligne %d  \n ",$1,nb_ligne,"------------");}
;
					   
//------------------PartieInstruction---------------------
partieInstruction: inst_aff partieInstruction    
					| inst_boucle partieInstruction 
					| inst_cond  partieInstruction
					| inst_aff
					|inst_boucle
					|inst_cond
;					


//-------------------Boucle------------
inst_boucle: mc_Pour identificateur op_AFF identificateur mc_jusque identificateur mc_Faire partieInstruction mc_Fait 
			|mc_Pour identificateur op_AFF constante mc_jusque constante mc_Faire partieInstruction mc_Fait 
			|mc_Pour constante op_AFF constante mc_jusque constante mc_Faire partieInstruction mc_Fait 
			|mc_Pour constante op_AFF identificateur mc_jusque constante mc_Faire partieInstruction mc_Fait 
			;

//------------------Instruction Condition-------------
inst_cond:mc_Faire inst_aff mc_SI parenthese_gauche cond  parenthese_droite 
; 



//------------------Condition-------------
cond: identificateur op_comp const_entier 
	 | identificateur op_comp const_reel 	     
	 | const_entier op_comp const_entier
	 | const_entier op_comp const_reel	
	 	 | const_reel op_comp const_entier	
	 | const_reel op_comp const_reel	
	 | identificateur op_comp identificateur 		     	 
; 


//------------------Instruction Affectation-----------
// on peut affecter un entier  à un reel ex: a<--5; ça devient a=5.0 , c'est pour ça qu'on a rajouté des conditions dans la ligne juste en dessous

inst_aff: identificateur op_AFF exp_arith pvg {    if(strcmp(ts[recherche($1)].TypeEntite,type)!=0 && !(strcmp(ts[recherche($1)].TypeEntite,"reel")==0 && strcmp(type,"entier")==0)) {printf("-----------Erreur de type d'affectation ! LIGNE : %d . La variable: %s declare commme %s  \n ",nb_ligne,$1,ts[recherche($1)].TypeEntite);}else {quadr(":=",tmp2," ",$1);}}
	      |identificateur op_AFF const_chaine pvg {strcpy(type,"chaine");if(strcmp(ts[recherche($1)].TypeEntite,type)!=0) {printf("-----------Erreur de type d'affectation ! LIGNE : %d . La variable: %s declare commme %s  \n ",nb_ligne,$1,ts[recherche($1)].TypeEntite);}else {quadr(":=",$3," ",$1);}}
; 
exp_arith: exp_arith op_arith identificateur  { if( $3==0 && strcmp("/",$2)==0) {printf("ERREUR SEMANTIQUE : division par zero ligne %d colonne %d \n ",nb_ligne,nb_colonne-1);} 
			else {sprintf(tmp,"%s",$3);sprintf(tmp3,"T%d",t);quadr($2,tmp2,tmp,tmp3);sprintf(tmp2,"T%d",t);t=t+1;}}
           |exp_arith op_arith const_reel  { if($3==0 && strcmp("/",$2)==0){printf(" ERREUR SEMANTIQUE: division par zero ligne %d colonne %d \n ",nb_ligne,nb_colonne-1);}
            else{sprintf(tmp,"%.2f",$3);sprintf(tmp3,"T%d",t);quadr($2,tmp2,tmp,tmp3);sprintf(tmp2,"T%d",t);t=t+1;}}
		   |exp_arith op_arith const_entier  { if ( $3==0 && strcmp("/",$2)==0) {printf(" ERREUR SEMANTIQUE: division par zero ligne %d colonne %d \n ",nb_ligne,nb_colonne-1);}
		   else {sprintf(tmp,"%d",$3);sprintf(tmp3,"T%d",t);quadr($2,tmp2,tmp,tmp3);sprintf(tmp2,"T%d",t);t=t+1;}}
		   |identificateur {strcpy(type,ts[recherche($1)].TypeEntite);sprintf(tmp2,"%s",$1);}
		   |const_reel {strcpy(type,"reel");sprintf(tmp2,"%.2f",$1);sprintf(tmp3,"T%.2f",$1);}
		   |const_entier {strcpy(type,"entier");sprintf(tmp2,"%d",$1);sprintf(tmp3,"T%d",$1);}
;

//----------------constante = entier ou reel -----------------
constante: const_entier {strcpy(type,"entier");}
		   | const_reel {strcpy(type,"reel");}
		   | const_chaine {strcpy(type,"chaine");}
;

%%
int main()
{
printf("Taper stop pour arreter \n");
yyparse();
printf("\n\n");
afficher();
printf("\n\n");
afficher_qdr();
system("PAUSE");

}
