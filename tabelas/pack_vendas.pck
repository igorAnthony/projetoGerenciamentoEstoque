create or replace package pack_vendas is
  PROCEDURE INSERE_PRODUTO(IO_CD_PRODUTO  IN OUT PRODUTO.CD_PRODUTO%TYPE,
                           I_DS_PRODUTO  IN PRODUTO.DS_PRODUTO%TYPE,
                           I_VL_UNITARIO IN PRODUTO.VL_UNITARIO%TYPE,
                           O_MENSAGEM    OUT VARCHAR2);
  ----------------------------------------------------------------------------------------------------------------------
  PROCEDURE INSERE_CLIENTE(I_NR_CPF        IN CLIENTE.NR_CPF%TYPE,
                           I_NM_CLIENTE     IN CLIENTE.NM_CLIENTE%TYPE,
                           I_DT_NASCIMENTO IN CLIENTE.DT_NASCIMENTO%TYPE,
                           O_MENSAGEM      OUT VARCHAR2);
  ----------------------------------------------------------------------------------------------------------------------
  PROCEDURE INSERE_VENDA(IO_CD_VENDA     IN OUT VENDA.CD_VENDA%TYPE,
                         I_CD_PRODUTO    IN PRODUTO.CD_PRODUTO%TYPE, 
                         I_QT_ADIQUIRIDA IN VENDA.QT_ADIQUIRIDA%TYPE,
                         I_NR_CPFCLIENTE IN CLIENTE.NR_CPF%TYPE,
                         I_DT_VENDA      IN VENDA.DT_VENDA%TYPE,
                         O_MENSAGEM      OUT VARCHAR2);
  ----------------------------------------------------------------------------------------------------------------------       
  PROCEDURE EXCLUI_CLIENTE(I_NR_CPF    IN CLIENTE.NR_CPF%TYPE,
                           O_MENSAGEM  OUT VARCHAR2);
  ----------------------------------------------------------------------------------------------------------------------
  PROCEDURE EXCLUI_PRODUTO(I_CD_PRODUTO    IN PRODUTO.CD_PRODUTO%TYPE,
                           O_MENSAGEM      OUT VARCHAR2);
  ----------------------------------------------------------------------------------------------------------------------
  PROCEDURE EXCLUI_VENDA(I_CD_VENDA    IN VENDA.CD_VENDA%TYPE,
                         O_MENSAGEM      OUT VARCHAR2);
  ----------------------------------------------------------------------------------------------------------------------           
end pack_vendas;
/
create or replace package body pack_vendas is
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------
  PROCEDURE INSERE_PRODUTO(IO_CD_PRODUTO IN OUT PRODUTO.CD_PRODUTO%TYPE,
                           I_DS_PRODUTO  IN PRODUTO.DS_PRODUTO%TYPE,
                           I_VL_UNITARIO IN PRODUTO.VL_UNITARIO%TYPE,
                           O_MENSAGEM    OUT VARCHAR2) IS
    E_GERAL EXCEPTION;
  BEGIN
    IF I_DS_PRODUTO IS NULL THEN
      O_MENSAGEM := 'Informe a descri??o do produto';
      RAISE E_GERAL;
    END IF;
    IF I_VL_UNITARIO IS NULL THEN
      O_MENSAGEM := 'Informe o valor unitario do produto';
      RAISE E_GERAL;
    END IF;
    
    IF IO_CD_PRODUTO IS NULL THEN
      BEGIN
        SELECT MAX(PRODUTO.CD_PRODUTO)
          INTO IO_CD_PRODUTO
          FROM PRODUTO;
      EXCEPTION
        WHEN OTHERS THEN
          IO_CD_PRODUTO := 0;
      END;
      IO_CD_PRODUTO := NVL(IO_CD_PRODUTO, 0) + 1;
    END IF;
    BEGIN
      INSERT INTO PRODUTO
        (CD_PRODUTO, DS_PRODUTO, VL_UNITARIO)
      VALUES
        (IO_CD_PRODUTO, I_DS_PRODUTO, I_VL_UNITARIO);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        UPDATE PRODUTO
           SET DS_PRODUTO = I_DS_PRODUTO, VL_UNITARIO = I_VL_UNITARIO
         WHERE CD_PRODUTO = IO_CD_PRODUTO;
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro inesperado ao inserir o produto. Erro:' ||
                      SQLERRM;
        RAISE E_GERAL;
    END;
  EXCEPTION
	  WHEN E_GERAL THEN
		  O_MENSAGEM := '[INSERE_PRODUTO] '||O_MENSAGEM;
	  WHEN OTHERS THEN
		  O_MENSAGEM := '[INSERE_PRODUTO: Erro] '||SQLERRM;
  END INSERE_PRODUTO;
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------
  PROCEDURE INSERE_CLIENTE(I_NR_CPF        IN CLIENTE.NR_CPF%TYPE,
                           I_NM_CLIENTE    IN CLIENTE.NM_CLIENTE%TYPE,
                           I_DT_NASCIMENTO IN CLIENTE.DT_NASCIMENTO%TYPE,
                           O_MENSAGEM      OUT VARCHAR2) IS
  
    E_GERAL EXCEPTION;
  
  BEGIN 
    
    IF I_NM_CLIENTE IS NULL THEN
      O_MENSAGEM := 'Informe o nome';
      RAISE E_GERAL;
    END IF;
    IF I_NR_CPF IS NULL THEN
      O_MENSAGEM := 'Informe o CPF';
      RAISE E_GERAL;
    END IF;
    IF LENGTH(I_NR_CPF) <> 11 THEN
      O_MENSAGEM := 'CPF invalido';
      RAISE E_GERAL;
    END IF;
    IF I_DT_NASCIMENTO IS NULL THEN
      O_MENSAGEM := 'Informe a data nascimento';
      RAISE E_GERAL;
    END IF;
    
    BEGIN
      INSERT INTO CLIENTE
        (NR_CPF, NM_CLIENTE, DT_NASCIMENTO)
      VALUES
        (I_NR_CPF, I_NM_CLIENTE, I_DT_NASCIMENTO);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        UPDATE CLIENTE
           SET NM_CLIENTE = I_NM_CLIENTE, DT_NASCIMENTO = I_DT_NASCIMENTO
         WHERE NR_CPF = I_NR_CPF;
      WHEN OTHERS THEN
        O_MENSAGEM := 'Erro inesperado ao inserir cliente. Erro:' ||
                      SQLERRM;
        RAISE E_GERAL;
    END;
    
  EXCEPTION
    WHEN E_GERAL THEN
      O_MENSAGEM := '[INSERE_CLIENTE]' || O_MENSAGEM;
    WHEN OTHERS THEN
      O_MENSAGEM := 'Erro de execu??o' || SQLERRM;
  END;
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------
  PROCEDURE INSERE_VENDA(IO_CD_VENDA     IN OUT VENDA.CD_VENDA%TYPE,
                         I_CD_PRODUTO    IN PRODUTO.CD_PRODUTO%TYPE, 
                         I_QT_ADIQUIRIDA IN VENDA.QT_ADIQUIRIDA%TYPE,
                         I_NR_CPFCLIENTE IN CLIENTE.NR_CPF%TYPE,
                         I_DT_VENDA      IN VENDA.DT_VENDA%TYPE,
                         O_MENSAGEM      OUT VARCHAR2) IS
    E_GERAL EXCEPTION;
    V_COUNT       NUMBER;
    V_VL_UNITPROD PRODUTO.VL_UNITARIO%TYPE;
  BEGIN
    IF I_CD_PRODUTO IS NULL THEN
      O_MENSAGEM := 'Informe o codigo do produto';
      RAISE E_GERAL;
    END IF;
    
    IF I_QT_ADIQUIRIDA IS NULL THEN
      O_MENSAGEM := 'Informe a quantidade adquirida';
      RAISE E_GERAL;
    END IF;
    
    IF I_NR_CPFCLIENTE IS NULL THEN
      O_MENSAGEM := 'Informe um CPF';
      RAISE E_GERAL;
    END IF;
    
    IF I_DT_VENDA IS NULL THEN
      O_MENSAGEM := 'Informe a data da venda';
      RAISE E_GERAL;
    END IF;
 
    BEGIN
      SELECT COUNT(*)
        INTO V_COUNT
        FROM CLIENTE
       WHERE NR_CPF = I_NR_CPFCLIENTE;
    EXCEPTION
      WHEN OTHERS THEN
        V_COUNT := 0;
    END;
    IF NVL(V_COUNT, 0) = 0 THEN
      O_MENSAGEM := 'O cliente informado n?o est? cadastrado';
      RAISE E_GERAL;
    END IF;
  
    BEGIN
      SELECT PRODUTO.VL_UNITARIO
        INTO V_VL_UNITPROD
        FROM PRODUTO
       WHERE PRODUTO.CD_PRODUTO = I_CD_PRODUTO; 
    EXCEPTION 
      WHEN OTHERS THEN 
       O_MENSAGEM := 'Erro inesperado ao buscar informa??es do produto para venda' || I_NR_CPFCLIENTE || 'Erro:' || SQLERRM;
       RAISE E_GERAL;
    END;
  
    V_COUNT := 0;
    BEGIN
      SELECT COUNT(*)
        INTO V_COUNT
        FROM PRODUTO
       WHERE CD_PRODUTO = I_CD_PRODUTO;
    EXCEPTION
      WHEN OTHERS THEN
        V_COUNT := 0;
    END;
  
    IF NVL(V_COUNT, 0) = 0 THEN
      O_MENSAGEM := 'O produto informado n?o est? cadastrado';
      RAISE E_GERAL;
    END IF;
    IF IO_CD_VENDA IS NULL THEN
     BEGIN
       SELECT MAX(VENDA.CD_VENDA) 
         INTO IO_CD_VENDA 
         FROM VENDA;
     EXCEPTION
       WHEN OTHERS THEN
         IO_CD_VENDA := 0;
     END;
     IO_CD_VENDA := NVL(IO_CD_VENDA, 0) + 1;
    END IF;
  
    BEGIN
      INSERT INTO VENDA
        (CD_VENDA,
         CD_PRODUTO,
         VL_UNITPROD,
         QT_ADIQUIRIDA,
         NR_CPFCLIENTE,
         DT_VENDA)
      VALUES
        (IO_CD_VENDA,
         I_CD_PRODUTO,
         V_VL_UNITPROD,
         I_QT_ADIQUIRIDA,
         I_NR_CPFCLIENTE,
         I_DT_VENDA);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        BEGIN
           UPDATE VENDA
              SET CD_VENDA = NVL(IO_CD_VENDA, CD_VENDA),
                  CD_PRODUTO = NVL(I_CD_PRODUTO, CD_PRODUTO),
                  VL_UNITPROD = NVL(V_VL_UNITPROD, VL_UNITPROD),
                  QT_ADIQUIRIDA = NVL(I_QT_ADIQUIRIDA, QT_ADIQUIRIDA),
                  NR_CPFCLIENTE = NVL(I_NR_CPFCLIENTE, NR_CPFCLIENTE)
            WHERE CD_VENDA = IO_CD_VENDA;
         EXCEPTION
          WHEN OTHERS THEN
           O_MENSAGEM := 'Erro inesperado ao atualizar a venda. Erro:' || SQLERRM;
          RAISE E_GERAL;
        END;
       WHEN OTHERS THEN
         O_MENSAGEM := 'Erro ao inserir a venda: ' || SQLERRM;
         RAISE E_GERAL;
   END;
  EXCEPTION
    WHEN E_GERAL THEN
      O_MENSAGEM := '[INSERE VENDA]' || O_MENSAGEM;
      ROLLBACK;
    WHEN OTHERS THEN
      O_MENSAGEM := 'Erro de execu??o' || SQLERRM;
  END;
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------
  PROCEDURE EXCLUI_CLIENTE(I_NR_CPF    IN CLIENTE.NR_CPF%TYPE,
                           O_MENSAGEM  OUT VARCHAR2) IS
    E_GERAL EXCEPTION;
    V_COUNT NUMBER;
  BEGIN
    BEGIN
     SELECT COUNT(*)
      INTO V_COUNT
      FROM VENDA
      WHERE VENDA.NR_CPFCLIENTE = I_NR_CPF;   
    EXCEPTION
      WHEN OTHERS THEN
        V_COUNT := 0; 
    END;
     
     IF V_COUNT > 0 THEN
       O_MENSAGEM := 'O cliente n?o pode ser excluido, pois existem vendas cadastradas que pertecem a ele';
       RAISE E_GERAL;
     END IF;
     
     BEGIN
       DELETE CLIENTE
         WHERE NR_CPF = I_NR_CPF;
     EXCEPTION
       WHEN OTHERS THEN
         O_MENSAGEM := 'Erro ao excluir o cliente ' || I_NR_CPF || ': ' || SQLERRM;
         RAISE E_GERAL;     
     END;
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;    
      O_MENSAGEM := '[EXCLUI_CLIENTE] ' || O_MENSAGEM;
    WHEN OTHERS THEN 
      ROLLBACK;
      O_MENSAGEM := '[EXCLUI_CLIENTE] Erro no procedimento de exclus?o do cliente:' ||SQLERRM;      
  END;
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------
  PROCEDURE EXCLUI_PRODUTO(I_CD_PRODUTO    IN PRODUTO.CD_PRODUTO%TYPE,
                           O_MENSAGEM      OUT VARCHAR2) IS
    E_GERAL EXCEPTION;
    V_COUNT NUMBER;
  BEGIN
    BEGIN
     SELECT COUNT(*)
      INTO V_COUNT
      FROM VENDA
      WHERE VENDA.CD_PRODUTO = I_CD_PRODUTO;   
    EXCEPTION
      WHEN OTHERS THEN
        V_COUNT := 0; 
    END;
     
     IF V_COUNT > 0 THEN
       O_MENSAGEM := 'O produto n?o pode ser excluido, pois existem vendas cadastradas que pertecem a ele';
       RAISE E_GERAL;
     END IF;
     
     BEGIN
       DELETE PRODUTO
         WHERE CD_PRODUTO = I_CD_PRODUTO;
     EXCEPTION
       WHEN OTHERS THEN
         O_MENSAGEM := 'Erro ao excluir o produto ' || I_CD_PRODUTO || ': ' || SQLERRM;
         RAISE E_GERAL;     
     END;
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;    
      O_MENSAGEM := '[EXCLUI_PRODUTO] ' || O_MENSAGEM;
    WHEN OTHERS THEN 
      ROLLBACK;
      O_MENSAGEM := '[EXCLUI_PRODUTO] Erro no procedimento de exclus?o do produto:' ||SQLERRM;      
  END;
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------
  PROCEDURE EXCLUI_VENDA(I_CD_VENDA    IN VENDA.CD_VENDA%TYPE,
                         O_MENSAGEM      OUT VARCHAR2) IS
    E_GERAL EXCEPTION;
  BEGIN          
     BEGIN
       DELETE VENDA
         WHERE CD_VENDA = I_CD_VENDA;
     EXCEPTION
       WHEN OTHERS THEN
         O_MENSAGEM := 'Erro ao excluir a venda ' || I_CD_VENDA || ': ' || SQLERRM;
         RAISE E_GERAL;     
     END;
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;    
      O_MENSAGEM := '[EXCLUI_VENDA] ' || O_MENSAGEM;
    WHEN OTHERS THEN 
      ROLLBACK;
      O_MENSAGEM := '[EXCLUI_VENDA] Erro no procedimento de exclus?o da venda:' ||SQLERRM;      
  END;  
end pack_vendas;
/
