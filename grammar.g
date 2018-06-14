grammar SIL;

@header {
import java.util.HashMap;
import java.util.Scanner;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
}

@members {
int count=1;// to check the line count
HashMap hash = new HashMap(); //for storing the identifier and their values
Scanner sc=new Scanner(System.in);  // used for retrieving input from the user
}	

program	
	: 	
	( 'PRINTLN' '('
	 (e1=expression // prints identifier/constants on the a newline with carriage return
	 	{  System.out.println($e1.result); count++; }
	 
	 
	| st=stringliteral// prints string literals on the a newline with carriage return
	 	{  String a=$st.text.toString().replace("\"","");  System.out.println(a); count++; } 
	  ) ')'
	 
	| 'PRINT' '(' //prints identifier/constants on the same line
	 (e2=expression  
	  	{  System.out.print($e2.result); count++; } 
	  
	  
	| st=stringliteral //prints string literals on the same line
	  	{  String a=$st.text.toString().replace("\"",""); System.out.print(a); count++;}
	 ) ')'
	  
	  
	| 'INTEGER' ident_expression (',' ident_expression)*//Initializes Identifiers 
		{count ++;} 
	
	
	| 'LET' IDENT '=' e2=expression
		{  //Assigns identifier a value
		Integer a= (Integer)hash.get($IDENT.text); //following is to check if the ident exists if it exists, 
							   //print error else add in hashmap 
		//the new ident and its value
		if(a!=null)
			{
				hash.put($IDENT.text,new Integer($e2.result));
				count++;
			}
		else 
			{
				System.err.println("Line "+count+": Please define the identifier first by INTEGER command. Identifier "
				+$IDENT.text+" undefined.");
				System.exit(0);
				count++;
			}
	 }
	| 'INPUT' user_Identifier (',' user_Identifier)*//Take value for all the identifier in the hash map 
		{
			count++;
		} 
	)*
	'END'
	;
	
	
user_Identifier: 
	IDENT
	{ 
		if(hash.containsKey($IDENT.text))//to take input value for ident from user, but check if it exists in the hashmap
		{
			System.out.println("Enter value for "+$IDENT.text+" : ");
			Object v=(Object)sc.nextInt(); 
			hash.put($IDENT.text,v);
		}
		else//else error and exit
		{
			System.err.println("Line "+count+": Please define the identifier first by INTEGER command. Identifier "
			+$IDENT.text+" undefined.");
			System.exit(0);	
		}
	}
	;

	
ident_expression :
	IDENT
	{ 
		if(hash.containsKey($IDENT.text))//check the hashmap if the identifier exisits, which mean a duplicate value hence issues errors
		{
			System.err.println("Line "+count+": Please use different identifier. Identifier "+$IDENT.text+" already in use.");
			System.exit(0);
		}
		else//else assignment an initial value 0
			hash.put($IDENT.text,new Integer(0));
		
	}
	;
//Expression -- 
term returns [int result]:
	IDENT 
        {    
	      
	        if(hash.containsKey($IDENT.text)) //checks if the identifier exists in the hash, if exists returns value
	        {
	        	$result=(Integer)hash.get($IDENT.text);
	        }
	        else//else error and exit
	        {
	        	System.err.println("Line "+count+": Please define the identifier first by INTEGER command. Identifier "+$IDENT.text+" undefined.");
	        	System.exit(0);
	        }
	}
	| '(' expression ')' //check if it contains expressions
		{
		$result =$expression.result;
		}
	
	| INTEGER //return an integer value
		{
		$result = Integer.parseInt($INTEGER.text);
		}
	;

unary	returns [int result]// check for signed input
	: 
	{ 
		boolean positive = true; 
	}
	('+' | '-' {positive = !positive; })* term
	{ 
		$result = $term.result;
		if(!positive)
			$result = -$result;
	} 
	;

mult returns [int result]//for multiply and division
	: op1=unary {$result = $op1.result;}
	(
	  '*' op2=unary {$result = $result * $op2.result;}
	| '/' op2=unary {$result = $result / $op2.result;}
	)*	
	;
	
expression returns [int result] //for addition and division
	: op1=mult {$result = $op1.result;}
	('+' op2=mult {$result = $result + $op2.result;}
	|'-' op2=mult {$result = $result - $op2.result;}
	)*
	;

stringliteral 	: '"' ('"''"'|~('"'))* '"'; //for string literal, accept " follower by either "" or any char but " and end with "

	
INTEGER	: ('0'..'9')+;  // one or more integer ranging from 0 to  9
COMMENT : '//' .* ('\n'|'\r'){ $channel=HIDDEN;}; //ignores single line comments
IDENT 	: ('a'..'z'|'A'..'Z') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')* ; // identifier should start with a..z or A..Z and followed by either zero or more a..z,A..Z, _ or 0..9
WS 	: (' ' | '\t' |'\f' |'\r'|'\n')+{$channel=HIDDEN;}; //ignore white space