Eigenclassifier for large-scale Image classification
+ Hai hàm chính:
	1. function MainClassify( dataset,start_Idx,end_Idx, step,optionR,approach)
		Hàm này thực hiện phân lớp theo eigenclassifer, trong đó:
		+ dataset: cho biết muốn test trên dataset nào: 
		           0: ILSVRC; 1: Caltech 256; 2: SUN 397		
		+  start_Idx: bắt đầu từ class nào 		
		+  end_Idx  : đến class nào
		+  step     : step bằng 1 hay -1
		            (ba tham số này cần trong trường hợp extract feature, training các class)
		+  optionR  : tham số xác định response matrix 
				     0: R = response matrix
					 1: R = Max(response matrix)
					 2: R = ground truth label
					 3: R = merge(response matrix, ground truth)
		+  approach : tham số xác định classifier theo cách nào
					 31: Two step approach
					 32: Joint optimization
					 321: Joint optimization with High dimension feature vectors
					 33: Kernel extension
					 34: Formulation as classification problem
		+ isAdd1	: 0/1 có xét bk trong cong thuc gk(vi) = <wk,vi> + bk hay không 
		+ OptEgis	: tính hàm eigs bằng cách nào
					1: eigs(P,Q,L)
					2: eigs(Pk,Qk,L)
					3: eigs(Q\P,L)
					4: eigs(Qk\Pk,L)

	2. function MainLabelTree( dataset,start_Idx,end_Idx, step,num_Child, isAuto)
		Hàm này thực hiện phân lớp theo label tree
		+  Các tham số dataset,start_Idx,end_Idx, step: có ý nghĩa như trong hàm MainClassify
		+  num_Child : số cây con trong mỗi node ( Q)
		+  isAuto	: cho biết cách xây dựng cây:
					0: cây được xây dựng sẵn trong dataset
					1: cây được build từ confusion matrix 1 các tự động
					2: cây nhị phân
		
+Cấu trúc thư mục:
+ Dataset
	+ features
		+ phow_LLCEncoder_SPMPooler_10000			
			+ train: lưu trữ feature vector của các ảnh trong tập training
			+ val  : lưu trữ feature vector của các ảnh trong tập validation
			+ test : lưu trữ feature vector của các ảnh trong tập testing
	+ imdb		
		+ trainxxx: tất cả các feature vector của tập training được lưu trữ trong 1 tập tin 
		+ valyyy   : tất cả các feature vector của tập validation được lưu trữ trong 1 tập tin 
		+ testzzz  : tất cả các feature vector của tập testing được lưu trữ trong 1 tập tin 
		             (xxx,yyy,zzz: cho biết tỉ lệ số ảnh train/val/test )   
	+ experiments
		+ binclassifiers
			+ trainxxx.blaall: cho biết kết quả training bằng pp OVA, mỗi class chọn xxx ảnh
				+ classname: thư mục tương ứng với tên lớp trong dataset
						     Thư mục mày chứa: 
								. model của binary OVA classifier (BOC)
								. kết quả predict của BOC trên tập testing
								. kết quả predict của BOC trên tập validation
		+ trainxxx.valyyy.testzzz
			+ RPQ
				+ train100.blaall : thư mục này chứa các tập tin lưu trữ kết quả R,P,Q,...và kết quả phân lớp theo phương pháp tính eigenvector wi, ...
			+ svr.svds
				+ train100.blaall: thư mục này chứa các regressor được train bằng SVR
					+ testzzz: chứa kết quả regressing của các regressor trên tập testzzz
			+ hic_auto_Qq: thư mục chứa cây labeltree T-q way và kết quả phân lớp theo labeltree.
			
			