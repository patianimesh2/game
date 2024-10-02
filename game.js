
let boxes = document.querySelectorAll(".box");

let resetbtn = document.querySelector(".reset");
let  btn2=document.querySelector(".btn2");
let msg=document.querySelector(".msg");
console.log(msg,btn2);
turnO = true;
const winpattern = [
  [0, 1, 2],
  [3, 4, 5],
  [6, 7, 8],
  [0, 3, 6],
  [0, 4, 6],
  [1, 4, 7],
  [2, 5, 8],
  [2, 4, 6],

];
boxes.forEach((box) => {
  box.addEventListener('click', () => {
    if (turnO) {
      box.innerText = "O";
      box.style.backgroundColor = "green";
      turnO = false;
    }
    else {
      box.innerText = "X";
      box.style.backgroundColor = "green";

      turnO = true;
    }
    box.disabled = true;
    checkWinner();



  });


});

const reset=()=>{
  turnO=true;
  enableBoxes();
  for(let box of boxes){
    box.innerText="";
    box.style.backgroundColor="aqua";
  }

}

const disableboxes=()=>{
 for(let box of boxes){
  box.disabled=true;
 }
}

// const enebleboxes=()=>{
//   for(let box of boxes){
//     box.disabled=false;
    

// }


const enableBoxes = () => {
  for (let box of boxes) {
    box.disabled = false;
    box.innerText = "";
  }
};



const showwinner=(winner)=>{
  msg.innerText=`Congratulation! Winner is ${winner} `;
  disableboxes();
  msg.classList.remove("hide");
  btn2.classList.remove("hide");
}


const checkWinner = () => {
  for (let pattern of winpattern) {
    //console.log(pattern[0], pattern[1], pattern[2]);
   
      let pos1Val=boxes[pattern[0]].innerText;
      let pos2Val=boxes[pattern[1]].innerText; 
      let pos3Val=boxes[pattern[2]].innerText;
    
    if(pos1Val !="" && pos2Val !="" && pos3Val !=""){
      if(pos1Val===pos2Val && pos2Val ===pos3Val){
        console.log("winner" ,pos1Val);
        showwinner(pos1Val);
      }
    }
    
    

  }
}

resetbtn.addEventListener("click",reset);
btn2.addEventListener("click",reset);
