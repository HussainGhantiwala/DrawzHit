const mongoose=require('mongoose');
const{playerSchema}=require('./Player')
const roomSchema= new mongoose.Schema({
    word:{ //words to guess
        require:true,
        type:String,
    },
    name:{ //name of the room
        require:true,
        type:String,
        unique:true,
        trim:true
    },
    occupancy:{
        require:true,
        type:Number,
        default:4
    },
    maxRounds:{
        require:true,
        type:Number,
    },
    currentRound:{
        require:true,
        type:Number,
        default:1,
    },
    players:[playerSchema],
    isJoin:{
       type:Boolean,
       default:true
    },
    turn:playerSchema,
    turnIndex:{
        type:Number,
        default:0
    }
})
const gameModel=mongoose.model('Room',roomSchema);
module.exports=gameModel;