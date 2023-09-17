/ / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |                                                                                                         p r o p s e n s e . m q 5   |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
  
 / /   b a s e d   o n   h t t p s : / / w d d b b d d b . n o t i o n . s i t e / P r o p - F i r m - P a s s e d - 5 m - S c a l p i n g - b a b 5 b a a 1 d a 3 7 4 4 1 0 9 c 1 0 8 f 9 5 0 1 2 a 2 8 1 a  
  
 # p r o p e r t y   c o p y r i g h t   " C o p y r i g h t   2 0 2 3 ,   M a r k   B e r n a r d i n i s "  
 # p r o p e r t y   v e r s i o n       " 1 . 0 0 "  
 # p r o p e r t y   i n d i c a t o r _ c h a r t _ w i n d o w  
  
 c l a s s   C P o i n t O f I n t e r e s t   {  
       p u b l i c :  
             i n t   i n d e x ;  
             d a t e t i m e   p e r i o d ;  
             d o u b l e   p r i c e ;  
             s t r i n g   n a m e ;  
 } ;  
  
 / /   T O D O :   d e f i n e   a   s t r u c t u r e   f o r   D S T   a d j u s t m e n t s   t o   L o n d o n   a n d   N e w   Y o r k   b a s e d   o n   t h e   D S T   r u l e s  
  
 e n u m   C A N D L E _ D I R   {  
       B U L L _ D I R   =   1 ,  
       N O N E _ D I R   =   0 ,  
       B E A R _ D I R   =   - 1  
 } ;  
  
 # p r o p e r t y   i n d i c a t o r _ p l o t s       0  
  
 # i n c l u d e   < G e n e r i c \ S t a c k . m q h >  
 # i n c l u d e   < G e n e r i c \ Q u e u e . m q h >  
 # i n c l u d e   < G e n e r i c \ A r r a y L i s t . m q h >  
 # i n c l u d e   " C i s N e w B a r . m q h "  
  
 C i s N e w B a r   c u r r e n t _ c h a r t ;   / /   i n s t a n c e   o f   t h e   C i s N e w B a r   c l a s s :   c u r r e n t   c h a r t  
  
 / / - - -   i n p u t   p a r a m e t e r s  
 i n p u t   i n t                         I n p M a x L e v e l s T o S h o w           =   5 ;                 / /   M a x   L e v e l s   t o   S h o w  
 i n p u t   i n t                         I n p L o o k b a c k B a r s                 =   9 9 9 ;                 / /   M a x   L o o k b a c k   t o   S h o w  
  
 i n p u t   c o l o r                     I n p B u l l i s h   =   c l r B l u e ;   / /   L e v e l   C o l o r   ( B u l l i s h )  
 i n p u t   c o l o r                     I n p B e a r i s h   =   c l r R e d ;   / /   L e v e l   C o l o r   ( B e a r i s h )  
  
 i n p u t   E N U M _ L I N E _ S T Y L E   I n p L i n e S t y l e   =   S T Y L E _ S O L I D ;   / /   L i n e   S t y l e  
 i n p u t   i n t                         I n p L i n e W i d t h   =   1 ;                 / /   L i n e   W i d t h  
  
 i n p u t   b o o l   I n p O n l y I n S e s s i o n   =   t r u e ;   / /   F i l t e r   w i t h   M a r k e t   S e s s i o n s  
  
 i n p u t   b o o l   I n p S h o w A s i a n S e s s i o n   =   t r u e ;   / /   S h o w   A s i a n   S e s s i o n  
 i n p u t   c o l o r   I n p A s i a n S e s s i o n N e x t L i n e   =   c l r F i r e B r i c k ;   / /   N e x t   A s i a n   S e s s i o n  
 i n p u t   b o o l   I n p A s i a n S e s s i o n   =   t r u e ;   / /   A s i a n   S e s s i o n  
 i n p u t   d o u b l e   I n p A s i a n S e s s i o n S t a r t   =   0 7 . 0 0 ;   / /   A s i a n   S e s s i o n   T i m e   ( S t a r t )  
 i n p u t   d o u b l e   I n p A s i a n S e s s i o n E n d   =   1 6 . 0 0 ;   / /   A s i a n   S e s s i o n   T i m e   ( E n d )  
 i n p u t   b o o l   I n p S h o w L o n d o n S e s s i o n   =   t r u e ;   / /   S h o w   L o n d o n   S e s s i o n  
 i n p u t   c o l o r   I n p L o n d o n S e s s i o n N e x t L i n e   =   c l r G o l d ;   / /   N e x t   L o n d o n   S e s s i o n  
 i n p u t   b o o l   I n p L o n d o n S e s s i o n   =   t r u e ;   / /   A s i a n   S e s s i o n  
 i n p u t   d o u b l e   I n p L o n d o n S e s s i o n S t a r t   =   1 5 . 0 0 ;   / /   L o n d o n   S e s s i o n   T i m e   ( S t a r t )  
 i n p u t   d o u b l e   I n p L o n d o n S e s s i o n E n d   =   0 0 . 0 0 ;   / /   L o n d o n   S e s s i o n   T i m e   ( E n d )  
 i n p u t   b o o l   I n p S h o w N e w Y o r k S e s s i o n   =   t r u e ;   / /   S h o w   N e w   Y o r k     S e s s i o n  
 i n p u t   c o l o r   I n p N e w Y o r k S e s s i o n N e x t L i n e   =   c l r L i m e G r e e n ;   / /   N e x t   N e w   Y o r k   S e s s i o n  
 i n p u t   b o o l   I n p N e w Y o r k S e s s i o n   =   t r u e ;   / /   A s i a n   S e s s i o n  
 i n p u t   d o u b l e   I n p N e w Y o r k S e s s i o n S t a r t   =   2 0 . 0 0 ;   / /   N e w   Y o r k   S e s s i o n   T i m e   ( S t a r t )  
 i n p u t   d o u b l e   I n p N e w Y o r k S e s s i o n E n d   =   0 5 . 0 0 ;   / /   N e w   Y o r k   S e s s i o n   T i m e   ( E n d )  
 i n p u t   d o u b l e   I n p S e s s i o n T i m e Z o n e s   =   8 . 0 0 ;   / /   T i m e z o n e  
  
 / / i n p u t   s t r i n g   H o s t = " 1 2 7 . 0 . 0 . 1 " ;  
 / / i n p u t   u s h o r t   P o r t = 8 0 8 1 ;  
  
 / / i n p u t   b o o l   I n p S h o w C u r r e n t B i a s   =     t r u e ;   / /   S h o w   C u r r e n t   B i a s  
 / / i n p u t   E N U M _ A N C H O R _ P O I N T   I n p L o c a t i o n ;   / /   L o c a t i o n  
 / / i n p u t   E N U M _ T E S T   I n p S i z e   =   E N U M _ A U T O ;   / /   S i z e  
  
 / / / / / /   C o n s t a n t s   / / / / / /  
 / / N O N E _ C O L O R   =   c o l o r . n e w ( c o l o r . w h i t e ,   1 0 0 )  
 / / c o n s t   i n t   L I N E _ O F F S E T   =   1 5  
 c o n s t   i n t   M A X _ L I N E   =   2 5 0 ;   / /   2 5 0   o n   e a c h   s i d e   =   5 0 0   l i n e s   i n   t o t a l  
 c o n s t   i n t   M A X _ B E A R _ C D _ L O O K B A C K   =   2 ;  
 c o n s t   s t r i n g   G M T   =   " G M T + 0 " ;  
 c o n s t   s t r i n g   T O K Y O _ F I X   =   " 0 0 5 5 - 0 1 0 0 " ;  
 c o n s t   s t r i n g   L O N D O N _ F I X   =   " 1 6 0 0 - 1 6 0 1 " ;  
  
 C A N D L E _ D I R   g B i a s   =   N O N E _ D I R ;  
  
 C A r r a y L i s t < C A N D L E _ D I R >   p r e v C a n d l e A r r ( ) ;  
 C A r r a y L i s t < C P o i n t O f I n t e r e s t   * >   b e a r L v A r r ( ) ;  
 C A r r a y L i s t < C P o i n t O f I n t e r e s t   * >   b u l l L v A r r ( ) ;  
  
 d o u b l e   m o s t R e c e n t B e a r   =   N U L L ;  
 d o u b l e   m o s t R e c e n t B u l l   =   N U L L ;  
 d o u b l e   l a s t B e a r C d O p e n   =   N U L L ;  
  
 d o u b l e   s e r v e r T i m e Z o n e O f f s e t   =   0 ;  
  
 i n t   l a s t B e a r C d I n d e x   =   N U L L ;  
 b o o l   i s L a s t B e a r C d B r o k e n   =   f a l s e ;  
  
 C S t a c k < C P o i n t O f I n t e r e s t   * >   i n v a l i d L v I n d e x A r r ( ) ;  
  
 b o o l   i s I n i t i a l i s e d   =   f a l s e ;  
 b o o l   i n A s ,   i n L d n ,   i n N y ;  
  
 v o i d   C l e a n ( C A r r a y L i s t < C P o i n t O f I n t e r e s t   * >   & b o o k )  
 {  
       w h i l e   ( b o o k . C o u n t ( )   >   0 )  
       {        
             C P o i n t O f I n t e r e s t   * p o i ;  
             i f   ( b o o k . T r y G e t V a l u e ( 0 ,   p o i ) )  
             {  
                   T r e n d D e l e t e ( 0 ,   p o i . n a m e ) ;  
                   b o o k . R e m o v e ( p o i ) ;  
                   d e l e t e   p o i ;  
             }  
       }  
 }  
  
 v o i d   O n D e i n i t ( c o n s t   i n t   r e a s o n )  
 {  
       P r i n t F o r m a t ( " S h u t t i n g   D o w n   ( p r o p s e n s e ) " ) ;  
  
       C l e a n ( b e a r L v A r r ) ;  
       C l e a n ( b u l l L v A r r ) ;  
        
       V L i n e D e l e t e ( 0 ,   S t r i n g F o r m a t ( " S E S S I O N _ N E X T [ % s ] " ,   " A s i a n   S e s s i o n " ) ) ;  
       V L i n e D e l e t e ( 0 ,   S t r i n g F o r m a t ( " S E S S I O N _ N E X T [ % s ] " ,   " L o n d o n   S e s s i o n " ) ) ;  
       V L i n e D e l e t e ( 0 ,   S t r i n g F o r m a t ( " S E S S I O N _ N E X T [ % s ] " ,   " N e w   Y o r k   S e s s i o n " ) ) ;  
        
       i s I n i t i a l i s e d   =   f a l s e ;  
 }  
  
 v o i d   O n T i m e r ( )  
 {  
       / /  
       i f   ( ! i s I n i t i a l i s e d )  
       {  
             / / i n t   d a y l i g h t S a v i n g s C o r r e c t i o n   =   T i m e D a y l i g h t S a v i n g s ( ) ;  
             s e r v e r T i m e Z o n e O f f s e t   =   ( d o u b l e ) ( ( i n t ) ( T i m e T r a d e S e r v e r ( )   -   T i m e G M T ( ) ) ) ;  
              
             P r i n t F o r m a t ( " I n i t i a l i s e d   ( p r o p s e n s e ) " ) ;  
             i s I n i t i a l i s e d   =   t r u e ;  
       }  
        
       / *  
       s t r i n g   c o o k i e = N U L L ,   h e a d e r s ;  
       c h a r       p o s t [ ] ,   r e s u l t [ ] ;  
       s t r i n g   u r l = " h t t p s : / / f i n a n c e . y a h o o . c o m " ;  
        
       i n t   r e s   =   W e b R e q u e s t ( " G E T " ,   u r l ,   c o o k i e ,   N U L L ,   5 0 0 ,   p o s t ,   0 ,   r e s u l t ,   h e a d e r s ) ;  
       i f   ( r e s   = =   - 1 )  
       {  
             P r i n t ( " E r r o r   i n   W e b R e q u e s t .   E r r o r   c o d e   =   " ,   G e t L a s t E r r o r ( ) ) ;  
       } e l s e {  
             i f   ( r e s   = =   2 0 0 )  
             {  
                   P r i n t F o r m a t ( " % c " ,   r e s u l t [ 0 ] ) ;  
             }  
             e l s e  
             {  
                   P r i n t ( " E r r o r " ) ;  
             }  
       } * /  
 }  
  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   C u s t o m   i n d i c a t o r   i n i t i a l i z a t i o n   f u n c t i o n                                                   |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 i n t   O n I n i t ( )  
 {  
       g B i a s   =   N O N E _ D I R ;  
        
       / / - - -   D e l a y   a   s e c o n d   t o   g i v e   M T 5   a   c h a n c e   t o   s t a r t u p   b e f o r e   a t t e m p t i n g   t o   q u e r y   t h e   s e r v e r  
       / / - - -   f o r   t i m e z o n e   i n f o r m a t i o n   a n d   o t h e r   b i t s   t h a t   c a n   c a u s e   f a i l u r e s   d u r i n g   s t a r t u p   o f   t h e   p l a t f o r m  
       E v e n t S e t T i m e r ( 1 ) ;  
        
       P r i n t F o r m a t ( " S t a r t e d   ( p r o p s e n s e ) " ) ;  
        
       / / - - -  
       r e t u r n ( I N I T _ S U C C E E D E D ) ;  
 }  
      
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   C u s t o m   i n d i c a t o r   i t e r a t i o n   f u n c t i o n                                                             |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 i n t   O n C a l c u l a t e ( c o n s t   i n t   r a t e s _ t o t a l ,  
                                 c o n s t   i n t   p r e v _ c a l c u l a t e d ,  
                                 c o n s t   d a t e t i m e   & t i m e [ ] ,  
                                 c o n s t   d o u b l e   & o p e n [ ] ,  
                                 c o n s t   d o u b l e   & h i g h [ ] ,  
                                 c o n s t   d o u b l e   & l o w [ ] ,  
                                 c o n s t   d o u b l e   & c l o s e [ ] ,  
                                 c o n s t   l o n g   & t i c k _ v o l u m e [ ] ,  
                                 c o n s t   l o n g   & v o l u m e [ ] ,  
                                 c o n s t   i n t   & s p r e a d [ ] )  
 {  
       / / - - -  
       i f   ( r a t e s _ t o t a l   = =   0 )  
             r e t u r n   ( r a t e s _ t o t a l ) ;  
  
       i f   ( ! i s I n i t i a l i s e d )   r e t u r n ( 0 ) ;  
  
       / / - - -   O n l y   c a l c u l a t e   h i s t o r i c a l l y   f r o m   I n p L o o k b a c k B a r s  
       i n t   s t a r t   =   M a t h M a x ( r a t e s _ t o t a l   -   I n p L o o k b a c k B a r s ,   p r e v _ c a l c u l a t e d ) ;  
  
       / / - - -   L o o p   t h r o u g h   t h e   p e r i o d s   i n   t h e   w i n d o w   e x c e p t   t h e   l a s t   c a n d l e   ( w h i c h   i s   t h e   a c t i v e   o n e )  
       f o r ( i n t   i   =   s t a r t ;   i   <   r a t e s _ t o t a l   -   1   & &   ! I s S t o p p e d ( ) ;   i + + )  
       {  
             P r o c e s s B a r ( i ,   t i m e ,   o p e n ,   h i g h ,   l o w ,   c l o s e ) ;  
       }  
        
       i n t   p e r i o d _ s e c o n d s = P e r i o d S e c o n d s ( _ P e r i o d ) ;                                           / /   N u m b e r   o f   s e c o n d s   i n   c u r r e n t   c h a r t   p e r i o d  
       d a t e t i m e   n e w _ t i m e = T i m e C u r r e n t ( ) / p e r i o d _ s e c o n d s * p e r i o d _ s e c o n d s ;   / /   T i m e   o f   b a r   o p e n i n g   o n   c u r r e n t   c h a r t  
       i f ( c u r r e n t _ c h a r t . i s N e w B a r ( n e w _ t i m e ) )   O n N e w B a r ( r a t e s _ t o t a l ,   t i m e ,   o p e n ,   h i g h ,   l o w ,   c l o s e ) ;   / /   W h e n   n e w   b a r   a p p e a r s   -   l a u n c h   t h e   N e w B a r   e v e n t   h a n d l e r  
  
       / / - - -   r e t u r n   v a l u e   o f   p r e v _ c a l c u l a t e d   f o r   n e x t   c a l l  
       r e t u r n ( r a t e s _ t o t a l ) ;  
 }  
  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
  
 b o o l   I n S e s s i o n ( d a t e t i m e   d t C u r r e n t ,   d o u b l e   s e s s S t a r t ,   d o u b l e   s e s s E n d ,   d o u b l e   s e s s T z )  
 {  
       M q l D a t e T i m e   d t C a n d l e ;  
       T i m e T o S t r u c t ( d t C u r r e n t ,   d t C a n d l e ) ;  
        
       d o u b l e   S e r v e r t i m e   =   d t C a n d l e . h o u r   -   ( s e r v e r T i m e Z o n e O f f s e t / 6 0 / 6 0 )   +   ( d t C a n d l e . m i n   *   0 . 0 1 )   +   s e s s T z ;  
        
       i f   ( ( s e s s E n d - s e s s S t a r t )   <   0   & &   ( S e r v e r t i m e < s e s s E n d   | |   S e r v e r t i m e   > =   s e s s S t a r t ) )  
       {  
             r e t u r n   ( t r u e ) ;  
       }  
              
       i f   ( ( s e s s E n d - s e s s S t a r t )   >   0   & &   S e r v e r t i m e   <   s e s s E n d   & &   S e r v e r t i m e   > =   s e s s S t a r t )  
       {  
             r e t u r n   ( t r u e ) ;  
       }  
              
       i f   ( s e s s S t a r t   +   s e s s E n d   = =   0 )  
       {  
             r e t u r n   ( t r u e ) ;  
       }  
              
       r e t u r n   ( f a l s e ) ;  
 }  
  
 v o i d   C r e a t e O r U p d a t e N e x t S e s s i o n ( s t r i n g   n a m e ,   d o u b l e   s e s s S t a r t ,   d o u b l e   s e s s T z ,   b o o l   i n S e s s i o n ,   c o l o r   b a c k g r o u n d )  
 {  
       d a t e t i m e   d t C u r r e n t   =   T i m e T r a d e S e r v e r ( ) ;  
  
       M q l D a t e T i m e   d t ;  
       T i m e T o S t r u c t ( d t C u r r e n t ,   d t ) ;  
  
       s t r i n g   l i n e N a m e   =   S t r i n g F o r m a t ( " S E S S I O N _ N E X T [ % s ] " ,   n a m e ) ;  
       d o u b l e   n e x t S e s s i o n S t a r t   =   ( d t . h o u r )   +   s e s s T z ;  
       i n t   i n c r e m e n t T o N e x t D a y   =   ( i n S e s s i o n )   ?   2 4 * 6 0 * 6 0   :   0 ;  
       / /   T O D O :   n e e d   t o   f i x   t h i s   a s   t h e r e   i s   t h e   p o t e n t i a l   f o r   a   l o s s   o f   d a t a   i f   w e   a r e   d e a l i n g   w i t h   t i m e z o n e s   o n   t h e   h a l f   h o u r   m a r k ,   i . e .   S A ,   A u s t a l i a  
       d t . h o u r   =   ( s e r v e r T i m e Z o n e O f f s e t / 6 0 / 6 0 )   -   s e s s T z   +   s e s s S t a r t ;  
       d t . m i n   =   0 ;  
       d t . s e c   =   0 ;  
       d a t e t i m e   n e x t   =   S t r u c t T o T i m e ( d t )   +   i n c r e m e n t T o N e x t D a y ;  
        
       i f   ( O b j e c t F i n d ( 0 ,   l i n e N a m e )   <   0 )  
       {  
             V L i n e C r e a t e ( 0 ,   l i n e N a m e ,   0 ,   n e x t ,   b a c k g r o u n d ,   S T Y L E _ D O T ,   1 ,   t r u e ,   f a l s e ) ;  
             O b j e c t S e t S t r i n g ( 0 ,   l i n e N a m e ,   O B J P R O P _ T E X T ,   n a m e ) ;  
       }  
       e l s e  
       {  
             / /   u p d a t e   n e x t   s e s s i o n   ( t h i s   w i l l   m o s t   l i k e l y   j u s t   s e t   t h e   v a l u e   t o   b e   t h e   s a m e   i t   w a s   p r e v i o u s l y )  
             V L i n e M o v e ( 0 ,   l i n e N a m e ,   n e x t ) ;  
       }  
 }  
  
 v o i d   P r o c e s s B a r ( c o n s t   i n t   c u r r e n t ,  
                               c o n s t   d a t e t i m e   & t i m e [ ] ,  
                               c o n s t   d o u b l e   & o p e n [ ] ,  
                               c o n s t   d o u b l e   & h i g h [ ] ,  
                               c o n s t   d o u b l e   & l o w [ ] ,  
                               c o n s t   d o u b l e   & c l o s e [ ] )  
 {  
       / /   i n i t i a l i s e   t o   v a l u e   o f   f i r s t   b a r  
       i f   ( c u r r e n t   = =   0 )  
       {  
             m o s t R e c e n t B u l l   =   N U L L ;  
             l a s t B e a r C d I n d e x   =   0 ;  
             l a s t B e a r C d O p e n   =   o p e n [ 0 ] ;  
             i s L a s t B e a r C d B r o k e n   =   f a l s e ;  
       }  
        
       b o o l   i n S e s s i o n A s i a   =   I n S e s s i o n ( t i m e [ c u r r e n t ] ,   I n p A s i a n S e s s i o n S t a r t ,   I n p A s i a n S e s s i o n E n d ,   I n p S e s s i o n T i m e Z o n e s ) ;  
       b o o l   a s i a n S e s s i o n O p e n   =   I n p O n l y I n S e s s i o n   & &   I n p A s i a n S e s s i o n   & &   i n S e s s i o n A s i a ;  
       i n A s   =   a s i a n S e s s i o n O p e n ;  
        
       b o o l   i n S e s s i o n L d n   =   I n S e s s i o n ( t i m e [ c u r r e n t ] ,   I n p L o n d o n S e s s i o n S t a r t ,   I n p L o n d o n S e s s i o n E n d ,   I n p S e s s i o n T i m e Z o n e s ) ;  
       i n L d n   =   I n p O n l y I n S e s s i o n   & &   I n p L o n d o n S e s s i o n   & &   i n S e s s i o n L d n ;  
  
       b o o l   i n S e s s i o n N y   =   I n S e s s i o n ( t i m e [ c u r r e n t ] ,   I n p N e w Y o r k S e s s i o n S t a r t ,   I n p N e w Y o r k S e s s i o n E n d ,   I n p S e s s i o n T i m e Z o n e s ) ;  
       i n N y   =   I n p O n l y I n S e s s i o n   & &   I n p N e w Y o r k S e s s i o n   & &   i n S e s s i o n N y ;  
              
       b o o l   i n S e s s   =   I n p O n l y I n S e s s i o n   ?   ( i n A s   | |   i n L d n   | |   i n N y )   :   t r u e ;  
  
       i f   ( I n p S h o w A s i a n S e s s i o n )  
       {  
             C r e a t e O r U p d a t e N e x t S e s s i o n ( " A s i a n   S e s s i o n " ,   I n p A s i a n S e s s i o n S t a r t ,   I n p S e s s i o n T i m e Z o n e s ,   i n S e s s i o n A s i a ,   I n p A s i a n S e s s i o n N e x t L i n e ) ;  
             / / C r e a t e O r U p d a t e C u r r e n t S e s s i o n ( I n p A s i a n S e s s i o n S t a r t ,   I n p A s i a n S e s s i o n E n d ,   I n p S e s s i o n T i m e Z o n e s ) ;  
       }  
        
       i f   ( I n p S h o w L o n d o n S e s s i o n )  
       {  
             C r e a t e O r U p d a t e N e x t S e s s i o n ( " L o n d o n   S e s s i o n " ,   I n p L o n d o n S e s s i o n S t a r t ,   I n p S e s s i o n T i m e Z o n e s ,   i n S e s s i o n L d n ,   I n p L o n d o n S e s s i o n N e x t L i n e ) ;  
             / / C r e a t e O r U p d a t e C u r r e n t S e s s i o n ( I n p L o n d o n S e s s i o n S t a r t ,   I n p L o n d o n S e s s i o n E n d ,   I n p S e s s i o n T i m e Z o n e s ) ;  
       }  
        
       i f   ( I n p S h o w N e w Y o r k S e s s i o n )  
       {  
             C r e a t e O r U p d a t e N e x t S e s s i o n ( " N e w   Y o r k   S e s s i o n " ,   I n p N e w Y o r k S e s s i o n S t a r t ,   I n p S e s s i o n T i m e Z o n e s ,   i n S e s s i o n N y ,   I n p N e w Y o r k S e s s i o n N e x t L i n e ) ;  
             / / C r e a t e O r U p d a t e C u r r e n t S e s s i o n ( I n p N e w Y o r k S e s s i o n S t a r t ,   I n p N e w Y o r k S e s s i o n E n d ,   I n p S e s s i o n T i m e Z o n e s ) ;  
       }  
        
       / /   T O D O :   a d d   t h e   F i x e s  
        
       / / i f   ( ! i n S e s s )  
       / / {  
             / / P r i n t F o r m a t ( " N o t   i n   s e s s i o n   d e t e c t e d   f o r   C A N D L E   % s   f o r   T Z   % f ,   % f   S E R V E R   O F F S E T   % f " ,   T i m e T o S t r i n g ( t i m e [ c u r r e n t ] ) ,   I n p S e s s i o n T i m e Z o n e s ,   8 . 0 ,   s e r v e r T i m e Z o n e O f f s e t ) ;  
       / / }  
        
       / /   i f   p r e v i o u s   c a n d l e   i s   n o t   n e u t r a l  
       i f   ( c u r r e n t   >   0   & &   ! I s N e u t r a l C a n d l e ( o p e n [ c u r r e n t - 1 ] ,   h i g h [ c u r r e n t - 1 ] ,   l o w [ c u r r e n t - 1 ] ,   c l o s e [ c u r r e n t - 1 ] ) )  
       {  
             p r e v C a n d l e A r r . A d d ( C a n d l e D i r ( o p e n [ c u r r e n t - 1 ] ,   h i g h [ c u r r e n t - 1 ] ,   l o w [ c u r r e n t - 1 ] ,   c l o s e [ c u r r e n t - 1 ] ) ) ;  
             i f   ( p r e v C a n d l e A r r . C o u n t ( )   >   M A X _ B E A R _ C D _ L O O K B A C K )  
                   p r e v C a n d l e A r r . R e m o v e A t ( 0 ) ;   / /   R e m o v e A t ( 0 )   =   s h i f t  
       }  
  
       C A N D L E _ D I R   l B i a s   =   g B i a s ;  
  
       b o o l   i s B e a r L v   =   f a l s e ;  
       i f   ( p r e v C a n d l e A r r . C o u n t ( )   = =   M A X _ B E A R _ C D _ L O O K B A C K )  
       {  
             C A N D L E _ D I R   d i r 1 ,   d i r 2 ;  
             p r e v C a n d l e A r r . T r y G e t V a l u e ( 0 ,   d i r 1 ) ;  
             p r e v C a n d l e A r r . T r y G e t V a l u e ( 1 ,   d i r 2 ) ;  
              
             i s B e a r L v   =   I s B u l l D i r ( d i r 1 )   & &   I s B e a r D i r ( d i r 2 )   & &   I s B e a r C a n d l e ( o p e n [ c u r r e n t ] ,   h i g h [ c u r r e n t ] ,   l o w [ c u r r e n t ] ,   c l o s e [ c u r r e n t ] ) ;  
       }  
        
       i f   ( i s B e a r L v )  
             l B i a s   =   B E A R _ D I R ;  
  
       i f   ( i n S e s s   & &   i s B e a r L v )  
       {  
             m o s t R e c e n t B e a r   =   c l o s e [ c u r r e n t   -   1 ] ;  
              
             C P o i n t O f I n t e r e s t   * p o i   =   n e w   C P o i n t O f I n t e r e s t ( ) ;  
             p o i . n a m e   =   S t r i n g F o r m a t ( " B E A R _ L V L [ % i ] " ,   c u r r e n t   -   1 ) ;  
             p o i . p e r i o d   =   t i m e [ c u r r e n t   -   1 ] ;  
             p o i . p r i c e   =   m o s t R e c e n t B e a r ;  
             p o i . i n d e x   =   c u r r e n t   -   1 ;  
                          
             b e a r L v A r r . A d d ( p o i ) ;  
             T r e n d C r e a t e ( 0 ,   p o i . n a m e ,   0 ,   p o i . p e r i o d ,   m o s t R e c e n t B e a r ,   p o i . p e r i o d + 6 0 0 ,   m o s t R e c e n t B e a r ,   I n p B e a r i s h ,   I n p L i n e S t y l e ,   I n p L i n e W i d t h ,   f a l s e ,   f a l s e ,   f a l s e ,   t r u e ) ;  
              
             T r i m L i n e A r r ( b e a r L v A r r ,   M A X _ L I N E ) ;  
       }  
        
       f o r   ( i n t   i   =   0 ;   i   <   b e a r L v A r r . C o u n t ( ) ;   i + + )  
       {  
             C P o i n t O f I n t e r e s t   * p o i ;  
             i f   ( b e a r L v A r r . T r y G e t V a l u e ( i ,   p o i ) )  
             {  
                   i f   ( c l o s e [ c u r r e n t ]   >   p o i . p r i c e   | |   I s L i n e E x p i r e d ( c u r r e n t ,   p o i ) )  
                   {  
                         i n v a l i d L v I n d e x A r r . P u s h ( p o i ) ;  
                   }  
             }  
       }  
        
       w h i l e   ( i n v a l i d L v I n d e x A r r . C o u n t ( )   >   0 )  
       {  
             C P o i n t O f I n t e r e s t   * l   =   i n v a l i d L v I n d e x A r r . P o p ( ) ;  
             b o o l   b S u c c e s s   =   b e a r L v A r r . R e m o v e ( l ) ;  
             T r e n d D e l e t e ( 0 ,   l . n a m e ) ;  
             d e l e t e   l ;  
       }  
        
       C o l o r i z e L e v e l s ( b e a r L v A r r ,   I n p B e a r i s h ) ;  
  
       / /   B u l l i s h   L e v e l s   :   b u l l   &   c l o s e   >   l a s t   b e a r   o p e n  
        
       i f   ( I s B e a r C a n d l e ( o p e n [ c u r r e n t ] ,   h i g h [ c u r r e n t ] ,   l o w [ c u r r e n t ] ,   c l o s e [ c u r r e n t ] ) )  
       {  
               l a s t B e a r C d O p e n   =   o p e n [ c u r r e n t ] ;  
               l a s t B e a r C d I n d e x   =   c u r r e n t ;  
               i s L a s t B e a r C d B r o k e n   =   f a l s e ;  
       }  
                
       b o o l   i s B u l l L v   =   I s B u l l C a n d l e ( o p e n [ c u r r e n t ] ,   h i g h [ c u r r e n t ] ,   l o w [ c u r r e n t ] ,   c l o s e [ c u r r e n t ] )   & &   c l o s e [ c u r r e n t ]   >   l a s t B e a r C d O p e n   & &   ! i s L a s t B e a r C d B r o k e n ;  
       i f   ( i s B u l l L v )  
       {  
               i s L a s t B e a r C d B r o k e n   =   t r u e ;  
               l B i a s   =   B U L L _ D I R ;  
       }  
        
       i f   ( i n S e s s   & &   i s B u l l L v )  
       {  
               m o s t R e c e n t B u l l   =   l a s t B e a r C d O p e n ;  
                
               C P o i n t O f I n t e r e s t   * p o i   =   n e w   C P o i n t O f I n t e r e s t ( ) ;  
               p o i . n a m e   =   S t r i n g F o r m a t ( " B U L L _ L V L [ % i ] " ,   c u r r e n t ) ;  
               p o i . p e r i o d   =   t i m e [ c u r r e n t ]   -   ( P e r i o d S e c o n d s ( )   *   ( c u r r e n t   -   l a s t B e a r C d I n d e x ) ) ;  
               p o i . p r i c e   =   m o s t R e c e n t B u l l ;   / /   S e t   t o   " P r e v i o u s "   C a n d l e s   O p e n   ( t h e   h i g h   o f   t h e   l a s t   b u l l )  
               p o i . i n d e x   =   l a s t B e a r C d I n d e x ;  
  
               b u l l L v A r r . A d d ( p o i ) ;  
                
               T r e n d C r e a t e ( 0 ,   p o i . n a m e ,   0 ,   p o i . p e r i o d ,   m o s t R e c e n t B u l l ,   p o i . p e r i o d + 6 0 0 ,   m o s t R e c e n t B u l l ,   I n p B u l l i s h ,   I n p L i n e S t y l e ,   I n p L i n e W i d t h ,   f a l s e ,   f a l s e ,   f a l s e ,   t r u e ) ;  
  
               T r i m L i n e A r r ( b u l l L v A r r ,   M A X _ L I N E ) ;  
       }  
        
       f o r   ( i n t   i   =   0 ;   i   <   b u l l L v A r r . C o u n t ( ) ;   i + + )  
       {  
             C P o i n t O f I n t e r e s t   * p o i ;  
             i f   ( b u l l L v A r r . T r y G e t V a l u e ( i ,   p o i ) )  
             {  
                   i f   ( c l o s e [ c u r r e n t ]   <   p o i . p r i c e   | |   I s L i n e E x p i r e d ( c u r r e n t ,   p o i ) )  
                   {  
                         i n v a l i d L v I n d e x A r r . P u s h ( p o i ) ;  
                   }  
             }  
       }  
                        
       w h i l e   ( i n v a l i d L v I n d e x A r r . C o u n t ( )   >   0 )  
       {  
             C P o i n t O f I n t e r e s t   * l   =   i n v a l i d L v I n d e x A r r . P o p ( ) ;  
             b o o l   b S u c c e s s   =   b u l l L v A r r . R e m o v e ( l ) ;  
             T r e n d D e l e t e ( 0 ,   l . n a m e ) ;  
             d e l e t e   l ;  
       }  
        
       C o l o r i z e L e v e l s ( b u l l L v A r r ,   I n p B u l l i s h ) ;  
        
       b o o l   b i a s C h a n g e d   =   ( l B i a s   ! =   g B i a s ) ;  
        
       i f   ( b i a s C h a n g e d )  
       {  
             g B i a s   =   l B i a s ;  
       }  
  
       / /   T O D O :   n e e d   t o   i m p l e m e n t   R e b a l a n c i n g  
 }  
  
 C A N D L E _ D I R   C a n d l e D i r ( c o n s t   d o u b l e   o p e n ,   c o n s t   d o u b l e   h i g h ,   c o n s t   d o u b l e   l o w ,   c o n s t   d o u b l e   c l o s e )  
 {  
       r e t u r n   c l o s e   >   o p e n   ?   B U L L _ D I R   :   ( c l o s e   <   o p e n   ?   B E A R _ D I R   :   N O N E _ D I R ) ;  
 }  
  
 b o o l   I s B u l l D i r ( C A N D L E _ D I R   d i r )  
 {  
       r e t u r n   d i r   = =   B U L L _ D I R ;  
 }  
  
 b o o l   I s B e a r D i r ( C A N D L E _ D I R   d i r )  
 {  
       r e t u r n   d i r   = =   B E A R _ D I R ;  
 }  
  
 b o o l   I s N e u t r a l D i r ( C A N D L E _ D I R   d i r )  
 {  
       r e t u r n   d i r   = =   N O N E _ D I R ;  
 }  
  
 b o o l   I s B u l l C a n d l e ( c o n s t   d o u b l e   o p e n ,   c o n s t   d o u b l e   h i g h ,   c o n s t   d o u b l e   l o w ,   c o n s t   d o u b l e   c l o s e )  
 {  
       r e t u r n   I s B u l l D i r ( C a n d l e D i r ( o p e n ,   h i g h ,   l o w ,   c l o s e ) ) ;  
 }  
  
 b o o l   I s B e a r C a n d l e ( c o n s t   d o u b l e   o p e n ,   c o n s t   d o u b l e   h i g h ,   c o n s t   d o u b l e   l o w ,   c o n s t   d o u b l e   c l o s e )  
 {  
       r e t u r n   I s B e a r D i r ( C a n d l e D i r ( o p e n ,   h i g h ,   l o w ,   c l o s e ) ) ;  
 }  
  
 b o o l   I s N e u t r a l C a n d l e ( c o n s t   d o u b l e   o p e n ,   c o n s t   d o u b l e   h i g h ,   c o n s t   d o u b l e   l o w ,   c o n s t   d o u b l e   c l o s e )  
 {  
       r e t u r n   I s N e u t r a l D i r ( C a n d l e D i r ( o p e n ,   h i g h ,   l o w ,   c l o s e ) ) ;  
 }  
  
 b o o l   I s L i n e E x p i r e d ( i n t   c u r r e n t ,   C P o i n t O f I n t e r e s t *   p o i )  
 {  
       r e t u r n   c u r r e n t   -   p o i . i n d e x   >   I n p L o o k b a c k B a r s ;  
 }  
  
 v o i d   T r i m L i n e A r r ( C A r r a y L i s t < C P o i n t O f I n t e r e s t   * >   & a r r ,   i n t   m a x )  
 {  
         i f   ( a r r . C o u n t ( )   >   m a x )  
         {  
             C P o i n t O f I n t e r e s t   * v a l u e ;  
             i f   ( a r r . T r y G e t V a l u e ( 0 ,   v a l u e ) )  
             {  
                   a r r . R e m o v e A t ( 0 ) ;  
                   T r e n d D e l e t e ( 0 ,   v a l u e . n a m e ) ;  
                   d e l e t e   v a l u e ;  
             }  
         }  
 }  
  
 v o i d   C o l o r i z e L e v e l s ( C A r r a y L i s t < C P o i n t O f I n t e r e s t   * >   & a r r ,   i n t   c l r )  
 {  
       C P o i n t O f I n t e r e s t   * v a l u e ;  
       f o r   ( i n t   i   =   0 ;   i   <   a r r . C o u n t ( ) ;   i + + )  
       {  
             i f   ( a r r . T r y G e t V a l u e ( i ,   v a l u e ) )  
             {  
                   i n t   v i s i b l e O n P e r i o d s   =   ( a r r . C o u n t ( )   -   i   >   I n p M a x L e v e l s T o S h o w )   ?   O B J _ N O _ P E R I O D S :   O B J _ A L L _ P E R I O D S ;  
                   O b j e c t S e t I n t e g e r ( 0 ,   v a l u e . n a m e ,   O B J P R O P _ T I M E F R A M E S ,   v i s i b l e O n P e r i o d s ) ;  
             }  
       }  
 }  
  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   N e w   b a r   e v e n t   h a n d l e r   f u n c t i o n                                                                       |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 v o i d   O n N e w B a r ( c o n s t   i n t   r a t e s _ t o t a l ,  
                             c o n s t   d a t e t i m e   & t i m e [ ] ,  
                             c o n s t   d o u b l e   & o p e n [ ] ,  
                             c o n s t   d o u b l e   & h i g h [ ] ,  
                             c o n s t   d o u b l e   & l o w [ ] ,  
                             c o n s t   d o u b l e   & c l o s e [ ] )  
 {  
       i f   ( r a t e s _ t o t a l   <   2 )   r e t u r n ;  
  
       / /   T h e   r a t e s _ t o t a l   w i l l   i n c l u d e   t h e   c u r r e n t l y   f o r m i n g   c a n d l e  
       / /   w e   o n l y   w a n t   t h e   f u l l y - f o r m e d   c a n d l e   t h e r e f o r e   g o   b a c k   1  
       / /   s i n c e   0   i n d e x   b a s e d ,   t a k e   1   f r o m   t h a t   w h i c h   e q u a t e s   t o   2  
       P r o c e s s B a r ( r a t e s _ t o t a l   -   2 ,   t i m e ,   o p e n ,   h i g h ,   l o w ,   c l o s e ) ;  
 }  
  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   C r e a t e   a   t r e n d   l i n e   b y   t h e   g i v e n   c o o r d i n a t e s                                           |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 b o o l   T r e n d C r e a t e ( c o n s t   l o n g                         c h a r t _ I D = 0 ,                 / /   c h a r t ' s   I D  
                                   c o n s t   s t r i n g                     n a m e = " T r e n d L i n e " ,     / /   l i n e   n a m e  
                                   c o n s t   i n t                           s u b _ w i n d o w = 0 ,             / /   s u b w i n d o w   i n d e x  
                                   d a t e t i m e                             t i m e 1 = 0 ,                       / /   f i r s t   p o i n t   t i m e  
                                   d o u b l e                                 p r i c e 1 = 0 ,                     / /   f i r s t   p o i n t   p r i c e  
                                   d a t e t i m e                             t i m e 2 = 0 ,                       / /   s e c o n d   p o i n t   t i m e  
                                   d o u b l e                                 p r i c e 2 = 0 ,                     / /   s e c o n d   p o i n t   p r i c e  
                                   c o n s t   c o l o r                       c l r = c l r R e d ,                 / /   l i n e   c o l o r  
                                   c o n s t   E N U M _ L I N E _ S T Y L E   s t y l e = S T Y L E _ S O L I D ,   / /   l i n e   s t y l e  
                                   c o n s t   i n t                           w i d t h = 1 ,                       / /   l i n e   w i d t h  
                                   c o n s t   b o o l                         b a c k = f a l s e ,                 / /   i n   t h e   b a c k g r o u n d  
                                   c o n s t   b o o l                         s e l e c t i o n = t r u e ,         / /   h i g h l i g h t   t o   m o v e  
                                   c o n s t   b o o l                         r a y _ l e f t = f a l s e ,         / /   l i n e ' s   c o n t i n u a t i o n   t o   t h e   l e f t  
                                   c o n s t   b o o l                         r a y _ r i g h t = f a l s e ,       / /   l i n e ' s   c o n t i n u a t i o n   t o   t h e   r i g h t  
                                   c o n s t   b o o l                         h i d d e n = t r u e ,               / /   h i d d e n   i n   t h e   o b j e c t   l i s t  
                                   c o n s t   l o n g                         z _ o r d e r = 0 )                   / /   p r i o r i t y   f o r   m o u s e   c l i c k  
 {  
       C h a n g e T r e n d E m p t y P o i n t s ( t i m e 1 , p r i c e 1 , t i m e 2 , p r i c e 2 ) ;  
       R e s e t L a s t E r r o r ( ) ;  
       i f ( ! O b j e c t C r e a t e ( c h a r t _ I D , n a m e , O B J _ T R E N D , s u b _ w i n d o w , t i m e 1 , p r i c e 1 , t i m e 2 , p r i c e 2 ) )  
           {  
             P r i n t ( _ _ F U N C T I O N _ _ ,  
                         " :   f a i l e d   t o   c r e a t e   a   t r e n d   l i n e !   E r r o r   c o d e   =   " , G e t L a s t E r r o r ( ) ) ;  
             r e t u r n ( f a l s e ) ;  
           }  
       O b j e c t S e t I n t e g e r ( c h a r t _ I D , n a m e , O B J P R O P _ C O L O R , c l r ) ;  
       O b j e c t S e t I n t e g e r ( c h a r t _ I D , n a m e , O B J P R O P _ S T Y L E , s t y l e ) ;  
       O b j e c t S e t I n t e g e r ( c h a r t _ I D , n a m e , O B J P R O P _ W I D T H , w i d t h ) ;  
       O b j e c t S e t I n t e g e r ( c h a r t _ I D , n a m e , O B J P R O P _ B A C K , b a c k ) ;  
       O b j e c t S e t I n t e g e r ( c h a r t _ I D , n a m e , O B J P R O P _ S E L E C T A B L E , s e l e c t i o n ) ;  
       O b j e c t S e t I n t e g e r ( c h a r t _ I D , n a m e , O B J P R O P _ S E L E C T E D , s e l e c t i o n ) ;  
       O b j e c t S e t I n t e g e r ( c h a r t _ I D , n a m e , O B J P R O P _ R A Y _ L E F T , r a y _ l e f t ) ;  
       O b j e c t S e t I n t e g e r ( c h a r t _ I D , n a m e , O B J P R O P _ R A Y _ R I G H T , r a y _ r i g h t ) ;  
       O b j e c t S e t I n t e g e r ( c h a r t _ I D , n a m e , O B J P R O P _ H I D D E N , h i d d e n ) ;  
       O b j e c t S e t I n t e g e r ( c h a r t _ I D , n a m e , O B J P R O P _ Z O R D E R , z _ o r d e r ) ;  
       r e t u r n ( t r u e ) ;  
 }  
    
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   T h e   f u n c t i o n   d e l e t e s   t h e   t r e n d   l i n e   f r o m   t h e   c h a r t .                             |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 b o o l   T r e n d D e l e t e ( c o n s t   l o n g       c h a r t _ I D = 0 ,               / /   c h a r t ' s   I D  
                                   c o n s t   s t r i n g   n a m e = " T r e n d L i n e " )   / /   l i n e   n a m e  
     {  
 / / - - -   r e s e t   t h e   e r r o r   v a l u e  
       R e s e t L a s t E r r o r ( ) ;  
 / / - - -   d e l e t e   a   t r e n d   l i n e  
       i f ( ! O b j e c t D e l e t e ( c h a r t _ I D , n a m e ) )  
           {  
             P r i n t ( _ _ F U N C T I O N _ _ ,  
                         " :   f a i l e d   t o   d e l e t e   a   t r e n d   l i n e !   E r r o r   c o d e   =   " , G e t L a s t E r r o r ( ) ) ;  
             r e t u r n ( f a l s e ) ;  
           }  
 / / - - -   s u c c e s s f u l   e x e c u t i o n  
       r e t u r n ( t r u e ) ;  
     }  
      
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   C h e c k   t h e   v a l u e s   o f   t r e n d   l i n e ' s   a n c h o r   p o i n t s   a n d   s e t   d e f a u l t       |  
 / / |   v a l u e s   f o r   e m p t y   o n e s                                                                                         |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 v o i d   C h a n g e T r e n d E m p t y P o i n t s ( d a t e t i m e   & t i m e 1 , d o u b l e   & p r i c e 1 ,  
                                                         d a t e t i m e   & t i m e 2 , d o u b l e   & p r i c e 2 )  
 {  
       i f ( ! t i m e 1 )  
             t i m e 1 = T i m e C u r r e n t ( ) ;  
       i f ( ! p r i c e 1 )  
             p r i c e 1 = S y m b o l I n f o D o u b l e ( S y m b o l ( ) , S Y M B O L _ B I D ) ;  
       i f ( ! t i m e 2 )  
           {  
             / / - - -   a r r a y   f o r   r e c e i v i n g   t h e   o p e n   t i m e   o f   t h e   l a s t   1 0   b a r s  
             d a t e t i m e   t e m p [ 1 0 ] ;  
             C o p y T i m e ( S y m b o l ( ) , P e r i o d ( ) , t i m e 1 , 1 0 , t e m p ) ;  
             / / - - -   s e t   t h e   s e c o n d   p o i n t   9   b a r s   l e f t   f r o m   t h e   f i r s t   o n e  
             t i m e 2 = t e m p [ 0 ] ;  
           }  
       i f ( ! p r i c e 2 )  
             p r i c e 2 = p r i c e 1 ;  
 }  
  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   C r e a t e   t h e   v e r t i c a l   l i n e                                                                                   |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 b o o l   V L i n e C r e a t e ( c o n s t   l o n g                         c h a r t _ I D = 0 ,                 / /   c h a r t ' s   I D  
                                   c o n s t   s t r i n g                     n a m e = " V L i n e " ,             / /   l i n e   n a m e  
                                   c o n s t   i n t                           s u b _ w i n d o w = 0 ,             / /   s u b w i n d o w   i n d e x  
                                   d a t e t i m e                             t i m e = 0 ,                         / /   l i n e   t i m e  
                                   c o n s t   c o l o r                       c l r = c l r R e d ,                 / /   l i n e   c o l o r  
                                   c o n s t   E N U M _ L I N E _ S T Y L E   s t y l e = S T Y L E _ S O L I D ,   / /   l i n e   s t y l e  
                                   c o n s t   i n t                           w i d t h = 1 ,                       / /   l i n e   w i d t h  
                                   c o n s t   b o o l                         b a c k = f a l s e ,                 / /   i n   t h e   b a c k g r o u n d  
                                   c o n s t   b o o l                         s e l e c t i o n = t r u e ,         / /   h i g h l i g h t   t o   m o v e  
                                   c o n s t   b o o l                         r a y = t r u e ,                     / /   l i n e ' s   c o n t i n u a t i o n   d o w n  
                                   c o n s t   b o o l                         h i d d e n = t r u e ,               / /   h i d d e n   i n   t h e   o b j e c t   l i s t  
                                   c o n s t   l o n g                         z _ o r d e r = 0 )                   / /   p r i o r i t y   f o r   m o u s e   c l i c k  
     {  
 / / - - -   i f   t h e   l i n e   t i m e   i s   n o t   s e t ,   d r a w   i t   v i a   t h e   l a s t   b a r  
       i f ( ! t i m e )  
             t i m e = T i m e C u r r e n t ( ) ;  
 / / - - -   r e s e t   t h e   e r r o r   v a l u e  
       R e s e t L a s t E r r o r ( ) ;  
 / / - - -   c r e a t e   a   v e r t i c a l   l i n e  
       i f ( ! O b j e c t C r e a t e ( c h a r t _ I D , n a m e , O B J _ V L I N E , s u b _ w i n d o w , t i m e , 0 ) )  
           {  
             P r i n t ( _ _ F U N C T I O N _ _ ,  
                         " :   f a i l e d   t o   c r e a t e   a   v e r t i c a l   l i n e !   E r r o r   c o d e   =   " , G e t L a s t E r r o r ( ) ) ;  
             r e t u r n ( f a l s e ) ;  
           }  
 / / - - -   s e t   l i n e   c o l o r  
       O b j e c t S e t I n t e g e r ( c h a r t _ I D , n a m e , O B J P R O P _ C O L O R , c l r ) ;  
 / / - - -   s e t   l i n e   d i s p l a y   s t y l e  
       O b j e c t S e t I n t e g e r ( c h a r t _ I D , n a m e , O B J P R O P _ S T Y L E , s t y l e ) ;  
 / / - - -   s e t   l i n e   w i d t h  
       O b j e c t S e t I n t e g e r ( c h a r t _ I D , n a m e , O B J P R O P _ W I D T H , w i d t h ) ;  
 / / - - -   d i s p l a y   i n   t h e   f o r e g r o u n d   ( f a l s e )   o r   b a c k g r o u n d   ( t r u e )  
       O b j e c t S e t I n t e g e r ( c h a r t _ I D , n a m e , O B J P R O P _ B A C K , b a c k ) ;  
 / / - - -   e n a b l e   ( t r u e )   o r   d i s a b l e   ( f a l s e )   t h e   m o d e   o f   m o v i n g   t h e   l i n e   b y   m o u s e  
 / / - - -   w h e n   c r e a t i n g   a   g r a p h i c a l   o b j e c t   u s i n g   O b j e c t C r e a t e   f u n c t i o n ,   t h e   o b j e c t   c a n n o t   b e  
 / / - - -   h i g h l i g h t e d   a n d   m o v e d   b y   d e f a u l t .   I n s i d e   t h i s   m e t h o d ,   s e l e c t i o n   p a r a m e t e r  
 / / - - -   i s   t r u e   b y   d e f a u l t   m a k i n g   i t   p o s s i b l e   t o   h i g h l i g h t   a n d   m o v e   t h e   o b j e c t  
       O b j e c t S e t I n t e g e r ( c h a r t _ I D , n a m e , O B J P R O P _ S E L E C T A B L E , s e l e c t i o n ) ;  
       O b j e c t S e t I n t e g e r ( c h a r t _ I D , n a m e , O B J P R O P _ S E L E C T E D , s e l e c t i o n ) ;  
 / / - - -   e n a b l e   ( t r u e )   o r   d i s a b l e   ( f a l s e )   t h e   m o d e   o f   d i s p l a y i n g   t h e   l i n e   i n   t h e   c h a r t   s u b w i n d o w s  
       O b j e c t S e t I n t e g e r ( c h a r t _ I D , n a m e , O B J P R O P _ R A Y , r a y ) ;  
 / / - - -   h i d e   ( t r u e )   o r   d i s p l a y   ( f a l s e )   g r a p h i c a l   o b j e c t   n a m e   i n   t h e   o b j e c t   l i s t  
       O b j e c t S e t I n t e g e r ( c h a r t _ I D , n a m e , O B J P R O P _ H I D D E N , h i d d e n ) ;  
 / / - - -   s e t   t h e   p r i o r i t y   f o r   r e c e i v i n g   t h e   e v e n t   o f   a   m o u s e   c l i c k   i n   t h e   c h a r t  
       O b j e c t S e t I n t e g e r ( c h a r t _ I D , n a m e , O B J P R O P _ Z O R D E R , z _ o r d e r ) ;  
 / / - - -   s u c c e s s f u l   e x e c u t i o n  
       r e t u r n ( t r u e ) ;  
     }  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   M o v e   t h e   v e r t i c a l   l i n e                                                                                       |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 b o o l   V L i n e M o v e ( c o n s t   l o n g       c h a r t _ I D = 0 ,       / /   c h a r t ' s   I D  
                               c o n s t   s t r i n g   n a m e = " V L i n e " ,   / /   l i n e   n a m e  
                               d a t e t i m e           t i m e = 0 )               / /   l i n e   t i m e  
     {  
 / / - - -   i f   l i n e   t i m e   i s   n o t   s e t ,   m o v e   t h e   l i n e   t o   t h e   l a s t   b a r  
       i f ( ! t i m e )  
             t i m e = T i m e C u r r e n t ( ) ;  
 / / - - -   r e s e t   t h e   e r r o r   v a l u e  
       R e s e t L a s t E r r o r ( ) ;  
 / / - - -   m o v e   t h e   v e r t i c a l   l i n e  
       i f ( ! O b j e c t M o v e ( c h a r t _ I D , n a m e , 0 , t i m e , 0 ) )  
           {  
             P r i n t ( _ _ F U N C T I O N _ _ ,  
                         " :   f a i l e d   t o   m o v e   t h e   v e r t i c a l   l i n e !   E r r o r   c o d e   =   " , G e t L a s t E r r o r ( ) ) ;  
             r e t u r n ( f a l s e ) ;  
           }  
 / / - - -   s u c c e s s f u l   e x e c u t i o n  
       r e t u r n ( t r u e ) ;  
     }  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   D e l e t e   t h e   v e r t i c a l   l i n e                                                                                   |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 b o o l   V L i n e D e l e t e ( c o n s t   l o n g       c h a r t _ I D = 0 ,       / /   c h a r t ' s   I D  
                                   c o n s t   s t r i n g   n a m e = " V L i n e " )   / /   l i n e   n a m e  
     {  
 / / - - -   r e s e t   t h e   e r r o r   v a l u e  
       R e s e t L a s t E r r o r ( ) ;  
 / / - - -   d e l e t e   t h e   v e r t i c a l   l i n e  
       i f ( ! O b j e c t D e l e t e ( c h a r t _ I D , n a m e ) )  
           {  
             P r i n t ( _ _ F U N C T I O N _ _ ,  
                         " :   f a i l e d   t o   d e l e t e   t h e   v e r t i c a l   l i n e !   E r r o r   c o d e   =   " , G e t L a s t E r r o r ( ) ) ;  
             r e t u r n ( f a l s e ) ;  
           }  
 / / - - -   s u c c e s s f u l   e x e c u t i o n  
       r e t u r n ( t r u e ) ;  
     } 