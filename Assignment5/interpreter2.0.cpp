#include "DRAM.cpp"

DRAM ram;

     
    
    
unordered_map<int, vector<string>> MIPS::getInstruction(){
    return instructions;
}



int MIPS::getLine(int pc) {
    return lineCount[pc];
}

void MIPS::incInstCount(int instruction){
    instCount[instruction] += 1;
}
// ------------instruction handling--------------------------

int MIPS::getLabelLine(string name){
    return labelLine[name];
}
vector<string> MIPS::getInst(int line){
    
    unordered_map<int, vector<string>>:: iterator it = instructions.find(line);
    return (it->second);
}

void MIPS::setInst(int line, vector<string> input){
    instructions[line] = input;
}

void MIPS::setInstLine(int addressInst, int line) {
    lineCount[addressInst] = line;
}

//  -------------------------ass4-addition-------------------------------------------

void MIPS::setLabel(string name, int address) {
    labelLine[name] = address;
}

bool MIPS::isInstPos(string name){
    if (labelLine.find(name) == labelLine.end()){
        return false;
    }
    else if (instructions.find(labelLine[name]) == instructions.end()){
        return false;
    }
    return true;
}

// --------------------------------------------------------------------------------------------------------

void MIPS::init(int core){

    coreNum = core;
}

void MIPS::printInstSet(vector<string> v){
    for (auto& it : v) { 
        string str = "";
        if (it != ")" && it != "(" && it != ",") {str = " ";}
        regSteps = regSteps + str +  it; 
    } 
}

//  -------------------------ass4-addition-------------------------------------------

void MIPS::printRegSet2(int k, vector<string> v,string p){

    string task = v.at(0);
    regSteps = regSteps + "\n-----------------------------Line: " +to_string(k) + "----------------------------";


    if (ram.regSteps != ""){
        regSteps += ram.regSteps + "\n";   
    }

    regSteps+= "\nClock: " + to_string(ram.clock) +"\n  Instruction called: ";
    printInstSet(v);   

    if (task == "add" || task == "sub" || task == "mul" || task == "addi" || task == "slt"){
        regSteps = regSteps+ "\n  Register modified : " + v.at(1) + " = " + to_string(allReg[coreNum].getRegValue(v.at(1))); 
    }
    else {
        regSteps += "\n" + p;
    }

    p = "";
    if (ram.isOn) {
        string a;
        for (auto& it : ram.currInst) { 
            a = a + " " +  it; 
        }
        p += "\n";
        p += "\n  [DRAM Execution going on: " + a+  ']';
        p += "\n  [Row active: " + to_string(ram.rowNum) + "]";
        string temp = "";
        int total = 0;
        int curr = 0;
        for (int i =0; i< 1024; i++) {
            if (!ram.rowSort[i].isEmpty()) {
                curr = ram.rowSort[i].size();
                total += curr;
                if (curr!=0) {
                    temp += to_string(i) + ":" + to_string(curr) + " ";
                }
            }
        }
        p = p + "\n  [Instructions in queue: " + to_string(curr) + " (" + temp + ")]";
        if (!ram.isEmpty()) {
            p += "\n  [Queue: \n";
            p += ram.printQ() + "  ]";
        }
    }      

    regSteps = regSteps + p + "\n";
    ram.regSteps = "";
}

// -   -------------------------------------------------------------------------------------------------------

void MIPS::printInstCount() {
    

    cout<< "\nExecution count of instructions in core " << to_string(coreNum +1)<< ":"<<endl;
    for (int i =0; i< 10; i++) {
        cout << inst[i] << ": "<< instCount[i]<<endl;
    }
    allReg[coreNum].printregVal();
}


void MIPS::printAll(){
    cout << "\n***********************************[CORE: " << to_string(coreNum+1) << "]**************************************" << endl;
    cout<< regSteps + "\n"<<endl;
    printInstCount();
    cout << "" << endl;
}


bool MIPS::isError(vector<string> v,int line) {

    
    string task = v.at(0);
    if (task == "add" || task == "sub" || task == "mul"  || task =="addi") {
        if (v.size() != 6){
            cout <<"Syntax error at line: "<<line<< " in core " << coreNum +1 << endl;
            return false;
        }
        else if (v.at(2) != "," || v.at(4) != ","){
            cout << "Syntax error at line: "<<line<< " in core " << coreNum +1 << endl;
            return false;
        }
        else if (allReg[coreNum].isReg(v.at(1)) ==false || allReg[coreNum].isReg(v.at(3)) ==false || (task != "addi" && allReg[coreNum].isReg(v.at(5)) == false)) {
            cout << "Syntax error: Invalid register at line: "<<line<< " in core " << coreNum +1 << endl;
            return false;
        }
        else if (v.at(1) == "$zero"){
            cout << "Syntax error: Cannot change value of zero register at line: "<<line<< " in core " << coreNum +1 << endl;
            return false;
        }
        else if (task == "addi"){
            try{
                stoi(v.at(5));
            }	
            catch(exception &err)
            {
                cout<<"Syntax error: Type mismatch at line: " <<line << " in core " << coreNum +1 << endl;
                return false;
            }
        }

        return true;
    }
    else if (task == "bne" || task == "beq" || task == "slt") {
        if (v.size() != 6 || v.at(2) != "," || v.at(4) != ",") {
            cout << "Syntax error at line: "<<line<< " in core " << coreNum +1 << endl;
            return false;
        }
        else if (allReg[coreNum].isReg(v.at(1)) == false || allReg[coreNum].isReg(v.at(3)) == false) {
            cout << "Syntax error: Invalid register at line: "<<line<< " in core " << coreNum +1 << endl;
            return false;
        }
        else if (task != "slt"){
            try {

                // -----------------------------------ass4-addition------------------------------------------------
                
                string temp = (v.at(5));

                // --------------------------------------------------------------------------------------------------------
                if (isInstPos(temp) == false){
            
                    cout<<"Invalid Instruction to be jumped at line: "<<line<< " in core " << coreNum +1 <<  endl;
                    return false;
                }
            }
            catch(exception &error){
                cout<<"Syntax error: Type mismatch at line: " <<line << " in core " << coreNum +1 << endl;
                return false;
            }
        }
        else {
            if (allReg[coreNum].isReg(v.at(5)) ==false){
                cout << "Syntax error: Invalid register at line: "<<line<< " in core " << coreNum +1 << endl;
                return false;
            } 
        }
        return true;
    }

    else if (task == "j"){
        if (v.size() != 2){
            cout << "Syntax error at line: "<<line<< " in core " << coreNum +1 << endl;
            return false;
        }
        else{
            try {

                // -----------------------------------ass4-addition------------------------------------------------

                string temp = (v.at(1));

                // --------------------------------------------------------------------------------------------------------
                if (isInstPos(temp) == false){

                        cout<<"Invalid Instruction to be jumped at line: "<<line<< " in core " << coreNum +1 <<  endl;
                    return false;
                }
            }
            catch(exception &error){
                cout<<"Syntax error: Type mismatch at line: " <<line << " in core " << coreNum +1 << endl;
                return false;
            }
        }
        return true;
    }

    else if (task == "lw" || task == "sw") {
        if (v.size() <6 || v.size() > 7){
            cout << "Syntax error at line: "<<line<< " in core " << coreNum +1 << endl;
            return false;
        }

        if (task == "lw" && v.at(1) == "$zero") {
            cout << "Syntax error: Cannot load value to zero register at line: "<<line<< " in core " << coreNum +1 << endl;
            return false;
        }

        if (v.size() == 6){
            if (v.at(2) != "," || v.at(3) != "(" || v.at(5) != ")"){
                cout << "Syntax error at line: "<<line<< " in core " << coreNum +1 << endl;
                return false;
            }
            else if (allReg[coreNum].isReg(v.at(1)) == false || allReg[coreNum].isReg(v.at(4)) == false){
                cout << "Syntax error: Invalid register at line: "<<line<< " in core " << coreNum +1 << endl;
                return false;
            }
            return true;
        }

        else{
            if (v.at(2) != "," || v.at(4) != "(" || v.at(6) != ")"){
                cout << "Syntax error at line: "<<line<< " in core " << coreNum +1 << endl;
                return false;
            }
            else if (allReg[coreNum].isReg(v.at(1)) == false || allReg[coreNum].isReg(v.at(5)) == false){
                cout << "Syntax error: Invalid register at line: "<<line<< " in core " << coreNum +1 << endl;
                return false;
            }
            else{
                try{
                    stoi(v.at(3));
                }	
                catch(exception &err)
                {
                    cout<<"Syntax error: Type mismatch at line: " <<line << " in core " << coreNum +1 << endl;
                    return false;
                }
            }
            return true;
        }
    }

    cout<<"Instruction not defined at line: " << line << endl;
    return false;
}


