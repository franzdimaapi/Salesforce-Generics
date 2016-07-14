/*****************************************************************
	Pagination Class for Custom Model / Wrapper Class

	Company: Accenture - Cloud First
	Author : Dimaapi, Franz Gerrard A.
	Comments: Created Class
	
	Modified By : Dimaapi, Franz Gerrard A.
				  Make this Pagination Class Applicable for all 
				  WrapperClasses

	How To Use : Call the Constructor with parameter (wrapper object list,wrapper class name)
	Sample 	   : SearchResultsPaginationController(wrapperModelList,'WrapperModel')
******************************************************************
	Empty Constructor - Instantiate recordsPerPage
	Parametized Constructor - Sets the list of objects that will
						      be use in this pagination :List<T>
	wrapperModelList - Wrapper Model Object List
	currentPage - Current Page of Pagination
	totalpage - Total Page of Pagination
	recordSize - Total Size of Wrapper Model Object List
	maxRecordPerPage - Max Record Per Page that can be controlled
	                  via Custom Settings
	claszName - Name of the Wrapper Class that will be paginated
 ******************************************************************/
 public class SearchResultsPaginationController {
	
	private List<Object> wrapperModelList;
	public List<Object> recordsPerPage {get;set;}
	private Integer currentPage = 1;
	private Integer totalPage = 0;
	private Integer recordSize;
	private Integer maxRecordPerPage;
	private String claszName;
	
	public SearchResultsPaginationController() {
		recordsPerPage = new List<Object>();
	}

	public SearchResultsPaginationController(List<Object> wrapperModelList, String claszName) {
		/* 
			Instantiate recordsPerPage
			Set wrapperModelList to passed wrapper model object list
			Pass List of WrapperClass Name
			Set recordSize to the wrapperModelList size
			Set maxRecordPerPage to its custom label value
			Set totalPage base on recordSize
		*/
		recordsPerPage = new List<Object>();
		this.claszName = claszName;
		this.wrapperModelList = wrapperModelList;
		recordSize = wrapperModelList.size();
		
		// Set customSettingMaxRecordPerPage base on Custom Settings
		Integer customSettingMaxRecordPerPage = Integer.valueOf(Search_Result__c.getInstance(
			UserInfo.getProfileId()).Number_of_row__c);

		// If Custom Settings for Max Record Per Page is 0 or Null make maxRecordPerPage = 0
		if(customSettingMaxRecordPerPage==0 || customSettingMaxRecordPerPage==null){
			customSettingMaxRecordPerPage = 0;
			
		}

		// Set maxRecordPerPage base on Custom Settings
		maxRecordPerPage = Integer.valueOf(customSettingMaxRecordPerPage);

		// If recordSize is greater than the maxRecordPerPage
		// TotalPage is recordSize/maxRecordPerPage but if the
		// recordSize over maxRecordPerPage has remainder
		// Add 1 to the TotalPage
		// Else Set TotalPage = 1
		if(maxRecordPerPage==0 && recordSize>0){
			totalPage = 1;
		} else if(recordSize > maxRecordPerPage){
			totalPage = Math.mod(recordSize,maxRecordPerPage) == 0? 
				recordSize / maxRecordPerPage: (recordSize / maxRecordPerPage ) + 1;
		}else{
			totalPage = 1;
		}
		
	}

	public void firstPage(){
		/* 
			Clear recordsPerPage, then Set recordsPerPage 
			base on the maxRecordPerPage or recordSize 
			from starting index then set the currentPage = 1
		*/

		recordsPerPage.clear();
		// Set limitPerPage to maxRecordPerPage
		Integer limitPerPage = maxRecordPerPage;
		// if recordSize is lesser than limitPerPage
		// then use recordSize as the limitPerPage
		if(recordSize < limitPerPage){
			limitPerPage = recordSize;
		}
		// if maxRecordPerPage equals to 0 and recordSize > 0 
		// create new Instance of Custom Wrapper from recordsPerPage
		if(maxRecordPerPage==0 && recordSize>0){
			recordsPerPage.add(Type.forName(claszName).newInstance());
		}
		// Set recordsPerPage base on wrapperModelList object from 0
		// to limitPerPage
		if(maxRecordPerPage!=0){
			for(Integer i = 0; i < limitPerPage;i++){
				recordsPerPage.add(wrapperModelList.get(i));
			}
		}

		// Set currentPage to 1
		currentPage = 1;
	}

	public void nextPage(){
		/* 
			Clear recordsPerPage, then Set recordsPerPage 
			base on the maxRecordPerPage or recordSize 
			then increase currentPage
		*/

		// If the currentPage is behind the lastPage then
		// call the lastPage() method
		if(currentPage== (totalPage - 1)){
			lastPage();
		}else{
			recordsPerPage.clear();
			// Set limitPerPage to product of maxRecordPerPage and (currentPage+1)
			Integer limitPerPage = maxRecordPerPage * (currentPage+1);
			// Set recordsPerPage base on wrapperModelList object from the product of currentPage
			// and maxRecordPerPage to limitPerPage
			for(Integer i = (currentPage * maxRecordPerPage); i < limitPerPage;i++){
				recordsPerPage.add(wrapperModelList.get(i));
			}
			// Increase currentpage to 1
			currentPage++;
		}
		
	}

	public void previousPage(){
		/* 
			Clear recordsPerPage, then Set recordsPerPage 
			base on the maxRecordPerPage or recordSize 
			then decrease currentPage
		*/

		// If the currentPage is 2 then
		// call the firstPage() method
		if(currentPage==2){
			firstPage();
		}else{
			recordsPerPage.clear();
			// Set limitPerPage to product of maxRecordPerPage and (currentPage-1);
			Integer limitPerPage = maxRecordPerPage * (currentPage - 1);
			// Set recordsPerPage base on wrapperModelList object from the product of (currentPage - 2)
			// and maxRecordPerPage to limitPerPage
			for(Integer i = (currentPage - 2) * maxRecordPerPage; i < limitPerPage;i++){
				recordsPerPage.add(wrapperModelList.get(i));
			}
			// Decrease currentPage to 1
			currentPage--;
		}
		
	}

	public void lastPage(){
		/* 
			Clear recordsPerPage, then Set recordsPerPage 
			base on the maxRecordPerPage or recordSize 
			then set currentPage to totalPage
		*/

		recordsPerPage.clear();
		// startCount = start of index that will be set on recordsPerPage
		// Set startCount to the product of maxRecordPerPage and ( totalPage - 1 )
		Integer startCount = (totalPage - 1) * maxRecordPerPage;
		// Set recordsPerPage base on wrapperModelList object from startCount
		// to recordSize
		for(Integer i = startCount; i < recordSize;i++){
			recordsPerPage.add(wrapperModelList.get(i));
		}

		// Set currentPage to totalPage
		currentPage = totalPage;
		
	}

	// render visualforce nextPage link
	// if totalPage greater than currentPage return true
	public Boolean hasNextPage{
		get{return maxRecordPerPage!=0 && totalPage>currentPage;}
	}

	// render visualforce nextPage link
	// if totalPage not equal to currentPage and recordsSize Not Null return true
	public Boolean hasLastPage{
		get{return (maxRecordPerPage!=0) && (totalPage!=currentPage) && (recordSize!=null);}
	}

	// render visualforce nextPage link
	// if currentPage greater than 1 return true
	public Boolean hasPreviousPage{
		get{return (maxRecordPerPage!=0) && currentPage>1;}
	}

	// render visualforce nextPage link
	// if currentPage not equal to 1 return true
	public Boolean hasFirstPage{
		get{return (maxRecordPerPage!=0) && currentPage!=1;}
	}


}